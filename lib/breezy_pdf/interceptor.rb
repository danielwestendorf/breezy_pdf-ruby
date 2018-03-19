# frozen_string_literal: true

module BreezyPDF
  # Intercept a Rack request
  class Interceptor
    attr_reader :app, :env

    def initialize(app, env)
      @app = app
      @env = env
    end

    def intercept!
      if intercept?
        response = Request.new(public_url).submit

        [
          302,
          { "Location" => response.download_url, "Content-Type" => "text/html", "Content-Length" => "0" },
          []
        ]
      else
        app.call(env)
      end
    end

    private

    def public_url
      "#{env['rack.url_scheme']}://#{env['SERVER_NAME']}:#{env['SERVER_PORT']}" \
      "#{env['PATH_INFO']}?#{env['QUERY_STRING']}"
    end

    def intercept?
      get? && matching_uri?
    end

    def matching_uri?
      matchers.any? { |regex| env["REQUEST_URI"].match?(regex) }
    end

    def get?
      env["REQUEST_METHOD"].match?(/get/i)
    end

    def matchers
      @matchers ||= BreezyPDF.middleware_path_matchers
    end
  end
end
