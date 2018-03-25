# frozen_string_literal: true

module BreezyPDF
  # API HTTP Response
  class Response
    def initialize(http_response)
      @http_response = http_response
      BreezyPDF.logger.fatal("[BreezyPDF] Network request failed: #{@http_response.body}") if failure?
    end

    def success?
      code >= 200 && code < 400
    end

    def failure?
      !success?
    end

    def method_missing(method, *_args, &_blk)
      if body.keys.include?(method.to_s)
        body[method.to_s]
      else
        super
      end
    end

    def respond_to_missing?(method, *)
      body.keys.include?(method.to_s)
    end

    private

    def code
      @code ||= @http_response.code.to_i
    end

    def body
      @body ||= JSON.parse(@http_response.body)
    rescue JSON::ParserError => e
      BreezyPDF.logger.fatal("[BreezyPDF] Server responded with invalid JSON: #{e}")
      raise e
    end
  end
end
