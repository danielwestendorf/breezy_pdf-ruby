# frozen_string_literal: true

module BreezyPDF::Intercept
  # :nodoc
  class PublicUrl < Base
    def call
      BreezyPDF.logger.info("[BreezyPDF] Requesting render of #{public_url}")
      response = BreezyPDF::RenderRequest.new(public_url).submit

      [
        302,
        { "Location" => response.download_url, "Content-Type" => "text/html", "Content-Length" => "0" },
        []
      ]
    end

    private

    def public_url
      "#{env['rack.url_scheme']}://#{env['SERVER_NAME']}#{port}" \
      "#{path}?#{env['QUERY_STRING']}"
    end

    def path
      path = env["PATH_INFO"]

      BreezyPDF.middleware_path_matchers.each do |regex|
        path = path.gsub(regex, "")
      end

      path
    end

    def port
      ":#{env['SERVER_PORT']}" unless [80, 443].include?(env["SERVER_PORT"].to_i)
    end
  end
end
