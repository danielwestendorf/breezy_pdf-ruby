# frozen_string_literal: true

module BreezyPDF::Intercept
  # :nodoc
  class PublicUrl < Base
    def call
      BreezyPDF.logger.info("[BreezyPDF] Requesting render of #{rendered_url}")
      response = BreezyPDF::RenderRequest.new(rendered_url, metadata).submit

      [
        302,
        { "Location" => response.download_url, "Content-Type" => "text/html", "Content-Length" => "0" },
        []
      ]
    end
  end
end
