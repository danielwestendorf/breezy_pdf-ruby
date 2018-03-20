# frozen_string_literal: true

module BreezyPDF
  # HTTP Client for BreezyPDF API
  class Client
    def post(path, body)
      uri = URI.parse(BreezyPDF.base_url + path)
      http = Net::HTTP.new(uri.host, uri.port).tap { |h| h.use_ssl = true }
      request = Net::HTTP::Post.new(uri.request_uri, headers)

      request.body = body.to_json

      Response.new http.request(request)
    end

    def put(path, body)
      uri = URI.parse(BreezyPDF.base_url + path)
      http = Net::HTTP.new(uri.host, uri.port).tap { |h| h.use_ssl = true }
      request = Net::HTTP::Put.new(uri.request_uri, headers)

      request.body = body.to_json

      Response.new http.request(request)
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
