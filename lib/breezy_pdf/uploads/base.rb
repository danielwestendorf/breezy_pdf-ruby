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
      BreezyPDF.logger.info(%([BreezyPDF] Starting private asset upload for #{@filename}))
      upload!
      complete_upload!

      BreezyPDF.logger.info(%([BreezyPDF] Private asset upload for #{@filename} completed))
      resource.presigned_url
    end

    private

    def client
      @client ||= BreezyPDF::Client.new
    end

    def file
      @file ||= File.open(@file_path)
    end

    def complete_upload!
      BreezyPDF.logger.info(%([BreezyPDF] Initiating completion of private asset upload for #{@filename}))
      client.put("/uploads/#{resource.id}", {})
    rescue Net::HTTP => error
      BreezyPDF.logger.fatal(%([BreezyPDF] Unable to complete private asset upload for #{@filename}))
      raise CompletionError, error.message
    end

    def upload!
      BreezyPDF.logger.info(%([BreezyPDF] Initiating private asset upload of #{@filename}))
      upload_response = upload_http.request(upload_request)

      return if upload_response.code.to_i == 204

      raise UploadError, "HTTP Status: #{upload_response.code}: #{upload_response.body}"
    rescue Net::HTTP => error
      BreezyPDF.logger.fatal(%([BreezyPDF] Unable to upload private asset #{@filename}))
      raise UploadError, error.message
    end

    def resource
      @resource ||= client.post("/uploads", resource_options).tap do
        BreezyPDF.logger.info(%([BreezyPDF] Initiating presign of private asset upload #{@filename}))
      end
    rescue Net::HTTP => error
      BreezyPDF.logger.fatal(%([BreezyPDF] Unable to presign private asset upload for #{@filename}))
      raise PresignError, error.message
    end

    def resource_options
      @resource_options ||= { filename: @filename, size: file.size, content_type: @content_type }
    end

    def upload_uri
      @upload_uri ||= URI.parse(resource.presigned_upload_url)
    end

    def upload_http
      @upload_http ||= Net::HTTP.new(upload_uri.host, upload_uri.port).tap { |http| http.use_ssl = true }
    end

    def upload_request
      @upload_request ||= Net::HTTP::Post.new(upload_uri.request_uri).tap do |post|
        file_form_data = FileFormData.new(resource.presigned_upload_fields, @content_type, @filename, file)

        post.content_type = "multipart/form-data; boundary=#{file_form_data.boundary}"
        post.body = file_form_data.data
      end
    end
  end
end
