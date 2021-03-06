# frozen_string_literal: true

require 'sidekiq'
require_dependency 'vba_documents/multipart_parser'
require 'vba_documents/object_store'
require 'vba_documents/upload_error'

module VBADocuments
  class UploadProcessor
    include Sidekiq::Worker

    META_PART_NAME = 'metadata'
    DOC_PART_NAME = 'content'
    SUBMIT_DOC_PART_NAME = 'document'
    REQUIRED_KEYS = %w[veteranFirstName veteranLastName fileNumber zipCode].freeze
    FILE_NUMBER_REGEX = /^\d{8,9}$/

    def perform(guid)
      upload = VBADocuments::UploadSubmission.find_by(guid: guid)
      tempfile, timestamp = download_raw_file(guid)
      begin
        parts = VBADocuments::MultipartParser.parse(tempfile.path)
        validate_parts(parts)
        validate_metadata(parts[META_PART_NAME])
        metadata = perfect_metadata(parts, upload, timestamp)
        response = submit(metadata, parts)
        process_response(response, upload)
        log_submission(metadata, upload)
      rescue VBADocuments::UploadError => e
        upload.update(status: 'error', code: e.code, detail: e.detail)
        Rails.logger.info('VBADocuments: Submission failure',
                          'uuid' => guid, 'source' => upload.consumer_name,
                          'code' => e.code, 'detail' => e.detail)
      ensure
        tempfile.close
        close_part_files(parts) if parts.present?
      end
    end

    private

    def log_submission(metadata, upload)
      page_total = metadata.select { |k, _| k.to_s.start_with?('numberPages') }.reduce(0) { |sum, (_, v)| sum + v }
      pdf_total = metadata.select { |k, _| k.to_s.start_with?('numberPages') }.count
      Rails.logger.info('VBADocuments: Submission success',
                        'uuid' => metadata['uuid'],
                        'source' => upload.consumer_name,
                        'docType' => metadata['docType'],
                        'pageCount' => page_total,
                        'pdfCount' => pdf_total)
    end

    def close_part_files(parts)
      parts[DOC_PART_NAME]&.close if parts[DOC_PART_NAME].respond_to? :close
      attachment_names = parts.keys.select { |k| k.match(/attachment\d+/) }
      attachment_names.each do |att|
        parts[att]&.close if parts[att].respond_to? :close
      end
    end

    def submit(metadata, parts)
      parts[DOC_PART_NAME].rewind
      body = {
        META_PART_NAME => metadata.to_json,
        SUBMIT_DOC_PART_NAME => to_faraday_upload(parts[DOC_PART_NAME], 'document.pdf')
      }
      attachment_names = parts.keys.select { |k| k.match(/attachment\d+/) }
      attachment_names.each_with_index do |att, i|
        parts[att].rewind
        body["attachment#{i + 1}"] = to_faraday_upload(parts[att], "attachment#{i + 1}.pdf")
      end
      PensionBurial::Service.new.upload(body)
    end

    def to_faraday_upload(file_io, filename)
      Faraday::UploadIO.new(
        file_io,
        Mime[:pdf].to_s,
        filename
      )
    end

    def process_response(response, upload)
      if response.success?
        upload.update(status: 'received')
      else
        map_downstream_error(response.status, response.body)
      end
    end

    def map_downstream_error(status, body)
      if status.between?(400, 499)
        raise VBADocuments::UploadError.new(code: 'DOC104',
                                            detail: "Downstream status: #{status} - #{body}")
      # Defined values: 500
      elsif status.between?(500, 599)
        raise VBADocuments::UploadError.new(code: 'DOC201',
                                            detail: "Downstream status: #{status} - #{body}")
      end
    end

    def download_raw_file(guid)
      store = VBADocuments::ObjectStore.new
      tempfile = Tempfile.new(guid)
      version = store.first_version(guid)
      store.download(version, tempfile.path)
      [tempfile, version.last_modified]
    end

    def validate_parts(parts)
      unless parts.key?(META_PART_NAME)
        raise VBADocuments::UploadError.new(code: 'DOC102',
                                            detail: 'No metadata part present')
      end
      unless parts[META_PART_NAME].is_a?(String)
        raise VBADocuments::UploadError.new(code: 'DOC102',
                                            detail: 'Incorrect content-type for metdata part')
      end
      unless parts.key?(DOC_PART_NAME)
        raise VBADocuments::UploadError.new(code: 'DOC103',
                                            detail: 'No document part present')
      end
      if parts[DOC_PART_NAME].is_a?(String)
        raise VBADocuments::UploadError.new(code: 'DOC103',
                                            detail: 'Incorrect content-type for document part')
      end
      # TODO: validate type and sequential naming of attachment parts
    end

    def validate_metadata(metadata_input)
      metadata = JSON.parse(metadata_input)
      missing_keys = REQUIRED_KEYS - metadata.keys
      if missing_keys.present?
        raise VBADocuments::UploadError.new(code: 'DOC102',
                                            detail: "Missing required keys: #{missing_keys.join(',')}")
      end
      non_string_vals = REQUIRED_KEYS.reject { |k| metadata[k].is_a? String }
      if non_string_vals.present?
        raise VBADocuments::UploadError.new(code: 'DOC102',
                                            detail: "Non-string values for keys: #{non_string_vals.join(',')}")
      end
      if (FILE_NUMBER_REGEX =~ metadata['fileNumber']).nil?
        raise VBADocuments::UploadError.new(code: 'DOC102',
                                            detail: 'Non-numeric or invalid-length fileNumber')
      end
    rescue JSON::ParserError
      raise VBADocuments::UploadError.new(code: 'DOC102',
                                          detail: 'Invalid JSON content')
    end

    def perfect_metadata(parts, upload, timestamp)
      metadata = JSON.parse(parts['metadata'])
      metadata['source'] = "#{upload.consumer_name} via VA API"
      metadata['receiveDt'] = timestamp.in_time_zone('US/Central').strftime('%Y-%m-%d %H:%M:%S')
      metadata['uuid'] = upload.guid
      doc_info = get_hash_and_pages(parts[DOC_PART_NAME])
      metadata['hashV'] = doc_info[:hash]
      metadata['numberPages'] = doc_info[:pages]
      attachment_names = parts.keys.select { |k| k.match(/attachment\d+/) }
      metadata['numberAttachments'] = attachment_names.size
      attachment_names.each_with_index do |att, i|
        att_info = get_hash_and_pages(parts[att])
        metadata["ahash#{i + 1}"] = att_info[:hash]
        metadata["numberPages#{i + 1}"] = att_info[:pages]
      end
      metadata
    end

    def get_hash_and_pages(file_path)
      {
        hash: Digest::SHA256.file(file_path).hexdigest,
        pages: PDF::Reader.new(file_path).pages.size
      }
    rescue PDF::Reader::MalformedPDFError
      raise VBADocuments::UploadError.new(code: 'DOC103',
                                          detail: 'Invalid PDF content')
    end
  end
end
