# frozen_string_literal: true

module BreezyPDF
  # API HTTP Response
  class Response
    def initialize(http_response)
      @http_response = http_response
    end

    def success?
      code >= 200 && code < 300
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
    end
  end
end
