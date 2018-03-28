# frozen_string_literal: true

module BreezyPDF::Intercept
  # :nodoc
  class PrivateUrl < Base
    def call
      raise BreezyPDF::Intercept::UnRenderable unless (200..299).cover?(status)

      BreezyPDF.logger.info(
        "[BreezyPDF] Requesting render of #{public_url} with metadata: #{html_private_asset.metadata}"
      )

      render_request = BreezyPDF::RenderRequest.new(public_url, html_private_asset.metadata).submit

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
      @public_url ||= BreezyPDF::Uploads::Base.new(
        html_private_asset.filename, html_private_asset.content_type, html_private_asset.file_path
      ).public_url
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

    def path
      env["PATH_INFO"].gsub(/\.pdf/, "")
    end

    def base_url
      "#{env['rack.url_scheme']}://#{env['SERVER_NAME']}#{port}"
    end

    def port
      ":#{env['SERVER_PORT']}" unless [80, 443].include?(env["SERVER_PORT"].to_i)
    end
  end
end
