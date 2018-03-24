# frozen_string_literal: true

module BreezyPDF
  # Request conversion of a public URL to PDF
  class RenderRequest
    def initialize(public_url, metadata = nil)
      @public_url = public_url
      @metadata   = metadata
    end

    def submit
      client.post("/pdf/public_urls", url_to_render: @public_url, metadata: @metadata.to_h)
    end

    private

    def client
      @client ||= Client.new
    end
  end
end
