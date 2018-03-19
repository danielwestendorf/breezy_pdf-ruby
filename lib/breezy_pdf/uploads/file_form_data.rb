# frozen_string_literal: true

require "securerandom"

module BreezyPDF::Uploads
  # Compose the form data for an HTTP POST of a file
  class FileFormData
    def initialize(fields, content_type, filename, file)
      @fields       = fields
      @content_type = content_type
      @filename     = filename
      @file         = file
    end

    def data
      @data ||= [
        field_data,
        file_data,
        closing_data
      ].join
    end

    def boundary
      @boundary ||= SecureRandom.hex
    end

    private

    def field_data
      field_data = []

      @fields.each do |key, value|
        field_data << "--#{boundary}\r\n"
        field_data << %(Content-Disposition: form-data; name="#{key}"\r\n\r\n)
        field_data << value.chomp + "\r\n"
      end

      field_data.join
    end

    def file_data
      [
        "--#{boundary}\r\n",
        %(Content-Disposition: form-data; name="file"; filename="#{@filename}"\r\n),
        "Content-Type: #{@content_type}\r\n\r\n",
        BreezyPDF::Gzip.compress(@file.read)
      ].join
    end

    def closing_data
      [
        "--#{boundary}\r\n",
        %(Content-Disposition: form-data; name="submit"\r\n\r\n),
        %(Upload) + "\r\n",
        "--#{boundary}--"
      ].join
    end
  end
end
