require 'pdf_fill/extras_generator'

# frozen_string_literal: true
module PdfFill
  class HashConverter
    ITERATOR = '%iterator%'

    attr_reader :extras_generator

    def initialize(date_strftime)
      @pdftk_form = {}
      @date_strftime = date_strftime
      @extras_generator = ExtrasGenerator.new
    end

    def convert_value(v)
      if [true, false].include?(v)
        v ? 1 : 0
      else
        v = v.to_s

        date_split = v.split('-')
        date_args = Array.new(3) { |i| date_split[i].to_i }

        if Date.valid_date?(*date_args)
          Date.new(*date_args).strftime(@date_strftime)
        else
          v
        end
      end
    end

    def has_overflow(key_data, value)
      limit = key_data.try(:[], :limit)

      limit.present? && value.size > limit
    end

    def add_to_extras(key_data, v, i)
      # TODO convert date
      text_prefix = key_data[:question]

      if i.present?
        text_prefix += " Line #{i + 1}"
      end

      @extras_generator.add_text(text_prefix, v)
    end

    def add_array_to_extras(arr, pdftk_keys)
      arr.each_with_index do |v, i|
        if v.is_a?(Hash)
          v.each do |key, val|
            add_to_extras(pdftk_keys[key], val, i)
          end
        else
          add_to_extras(pdftk_keys, v, i)
        end
      end
    end

    def set_value(k, v, key_data, i)
      new_value = convert_value(v)

      if has_overflow(key_data, new_value)
        add_to_extras(key_data, new_value, i)

        new_value = "See add'l info page"
      end

      @pdftk_form[k] = new_value
    end

    def check_for_overflow(arr, pdftk_keys)
      # TODO check if array is over array limit
      arr.each do |item|
        next if item.blank? || !item.is_a?(Hash)

        item.each do |k, v|
          if has_overflow(pdftk_keys[k], v)
            return true
          end
        end
      end

      false
    end

    def transform_data(form_data:, pdftk_keys:, i: nil)
      return if form_data.nil? || pdftk_keys.nil?

      case form_data
      when Array
        has_overflow = check_for_overflow(form_data, pdftk_keys)

        if has_overflow
          hash = form_data[0]
          first_key = hash.keys[0]

          # TODO make text constant
          # TODO put entire array in addl info page
          transform_data(
            form_data: { first_key => "See add'l info page" },
            pdftk_keys: pdftk_keys,
            i: 0
          )

          add_array_to_extras(form_data, pdftk_keys)
        else
          form_data.each_with_index do |v, idx|
            transform_data(form_data: v, pdftk_keys: pdftk_keys, i: idx)
          end
        end
      when Hash
        form_data.each do |k, v|
          transform_data(
            form_data: v,
            pdftk_keys: pdftk_keys[k],
            i: i
          )
        end
      else
        key = pdftk_keys[:key]
        key = key.gsub(ITERATOR, i.to_s) unless i.nil?
        set_value(key, form_data, pdftk_keys, i)
      end

      @pdftk_form
    end
  end
end