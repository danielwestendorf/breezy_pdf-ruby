# frozen_string_literal: true

module BreezyPDF::Intercept
  # :nodoc
  class PrivateUrl < Base
    def call
      raise BreezyPDF::Intercept::UnRenderable unless (200..299).cover?(status)

      BreezyPDF.logger.info(
        "[BreezyPDF] Requesting render of #{rendered_url} with metadata: #{metadata}"
      )

      render_request = BreezyPDF::RenderRequest.new(public_url, metadata).submit

      BreezyPDF.logger.info("[BreezyPDF] Redirect to pdf at #{render_request.download_url}")
      [
        302,
        { "Location" => render_request.download_url, "Content-Type" => "text/html", "Content-Length" => "0" },
        []
      ]
    rescue BreezyPDF::Intercept::UnRenderable
      BreezyPDF.logger.fatal("[BreezyPDF] Unable to render HTML, server responded with HTTP Status #{status}")

      response
    end

    private

    def public_url
      @public_url ||= upload.public_url
    end

    def metadata
      super.merge(
        "upload_ids" => upload_ids
      ).merge(html_private_asset.metadata)
    end

    def upload_ids
      [upload.id] + html_private_asset.upload_ids
    end

    def upload
      @upload ||= BreezyPDF::Uploads::Base.new(
        html_private_asset.filename, html_private_asset.content_type, html_private_asset.file_path
      )
    end

    def html_private_asset
      @html_private_asset ||= BreezyPDF::Resources::HTML.new(base_url, body)
    end

    def status
      @status ||= response[0]
    end

    def headers
      @headers ||= response[1]
    end

    def body
      @body ||= response[2].respond_to?(:body) ? response[2].body : response[2].join
    end

    def response
      @response ||= app.call(doctored_env)
    end

    def doctored_env
      env.dup.tap do |hash|
        hash["HTTP_ACCEPT"] = "text/html"
        hash["PATH_INFO"]   = path
      end
    end
  end
end
