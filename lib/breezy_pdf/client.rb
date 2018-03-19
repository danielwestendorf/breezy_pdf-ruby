# frozen_string_literal: true

require "net/http"
require "uri"

module BreezyPDF
  # HTTP Client for BreezyPDF API
  class Client
    def post(path, body)
      uri = URI.parse(BreezyPDF.base_url + path)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, headers)

      request.body = body.to_json

      http.request(request)
    end

    private

    def headers
      {
        "Content-Type":  "application/json",
        "Authorization": "Bearer #{BreezyPDF.secret_api_key}"
      }
    end

    def success?(code)
      code >= 200 && code < 300
    end
  end
end
