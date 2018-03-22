# frozen_string_literal: true

module BreezyPDF::Intercept
  # :nodoc
  class PrivateUrl < Base
    def call
      response = BreezyPDF::RenderRequest.new(public_url, html_private_asset.metadata).submit

      [
        302,
        { "Location" => response.download_url, "Content-Type" => "text/html", "Content-Length" => "0" },
        []
      ]
    end

    private

    def public_url
      @public_url ||= BreezyPDF::Uploads::Base.new(
        html_private_asset.filename, html_private_asset.content_type, html_private_asset.file_path
      ).public_url
    end

    def html_private_asset
      @html_private_asset ||= BreezyPDF::PrivateAssets::HTML.new(base_url, body)
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
        hash["PATH_INFO"] = path
      end
    end

    def path
      path = env["PATH_INFO"]

      BreezyPDF.middleware_path_matchers.each do |regex|
        path = path.gsub(regex, "")
      end

      path
    end

    def base_url
      "#{env['rack.url_scheme']}://#{env['SERVER_NAME']}:#{env['SERVER_PORT']}"
    end
  end
end
