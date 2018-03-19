# frozen_string_literal: true

module BreezyPDF::Uploads
  # Upload an asset
  class Base
    def initialize(filename, content_type, file_path)
      @filename     = filename
      @content_type = content_type
      @file_path    = file_path
    end

    def public_url
      upload!
      complete_upload!

      resource["presigned_url"]
    end

    private

    def client
      @client ||= Client.new
    end

    def file
      @file ||= File.open(@file_path)
    end

    def complete_upload!
      client.put(resource["resource_url"])
    rescue Net::HTTP => error
      raise CompletionError, error.message
    end

    def upload!
      upload_response = upload_http.request(upload_request)

      return if upload_response.code.to_i == 204

      raise UploadError, "HTTP Status: #{upload_response.code}: #{upload_response.body}"
    rescue Net::HTTP => error
      raise UploadError, error.message
    end

    def resource
      @resource ||= client.post("/uploads", filename: @filename, size: file.size)
    rescue Net::HTTP => error
      raise PresignError, error.message
    end

    def upload_uri
      @upload_uri ||= URI.parse(resource["presigned_upload_url"])
    end

    def upload_http
      @upload_http ||= Net::HTTP.new(upload_uri.host, upload_uri.port).tap { |http| http.use_ssl = true }
    end

    def upload_request
      @upload_request ||= Net::HTTP::Post.new(upload_uri.request_uri).tap do |post|
        file_form_data = FileFormData.new(resource["presigned_upload_fields"], @content_type, @filename, file)

        post.content_type = "multipart/form-data; boundary=#{file_form_data.boundary}"
        post.body = file_form_data.data
      end
    end
  end
end
