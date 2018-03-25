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
      "#{env['rack.url_scheme']}://#{env['SERVER_NAME']}:#{env['SERVER_PORT']}" \
      "#{path}?#{env['QUERY_STRING']}"
    end

    def path
      path = env["PATH_INFO"]

      BreezyPDF.middleware_path_matchers.each do |regex|
        path = path.gsub(regex, "")
      end

      path
    end
  end
end
