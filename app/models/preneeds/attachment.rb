# frozen_string_literal: true
module Preneeds
  class Attachment
    include Virtus.model

    attribute :attachment_type, Preneeds::AttachmentType
    attribute :sending_source, String, default: 'vets.gov'
    attribute :file, (Rails.env.production? ? CarrierWave::Storage::AWSFile : CarrierWave::SanitizedFile)

    attr_reader :guid

    def initialize(*args)
      super
      @guid = SecureRandom.uuid
    end

    def as_eoas
      {
        attachmentType: {
          attachmentTypeId: attachment_type.attachment_type_id
        }.compact,
        dataHandler: @guid,
        description: file.filename,
        sendingSource: sending_source
      }.compact
    end
  end
end
