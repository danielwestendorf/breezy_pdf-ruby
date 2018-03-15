require "json"

module BreezyPDF
  class Request
    def initialize(public_url)
      @public_url = public_url
    end

    def submit
      Response.new client.post("/pdf/public_urls", url_to_render: @public_url)
    end

    private

    def client
      @client ||= Client.new
    end
  end
end
