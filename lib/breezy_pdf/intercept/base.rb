# frozen_string_literal: true

module BreezyPDF::Intercept
  # :nodoc
  class Base
    attr_reader :app, :env

    def initialize(app, env)
      @app = app
      @env = env
      @start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    private

    def timing
      @timing ||= Process.clock_gettime(Process::CLOCK_MONOTONIC) - @start_time
    end

    def metadata
      BreezyPDF.default_metadata.merge(
        "requested_url" => requested_url, "rendered_url" => rendered_url
      )
    end

    def rendered_url
      "#{env['rack.url_scheme']}://#{env['SERVER_NAME']}#{port}" \
      "#{path}#{query_string}"
    end

    def requested_url
      "#{env['rack.url_scheme']}://#{env['SERVER_NAME']}#{port}" \
      "#{env['PATH_INFO']}#{query_string}"
    end

    def base_url
      "#{env['rack.url_scheme']}://#{env['SERVER_NAME']}#{port}"
    end

    def port
      ":#{env['SERVER_PORT']}" unless [80, 443].include?(env["SERVER_PORT"].to_i)
    end

    def path
      env["PATH_INFO"].gsub(/\.pdf/, "")
    end

    def query_string
      return "" if env["QUERY_STRING"].nil?

      env["QUERY_STRING"] == "" ? "" : "?#{env['QUERY_STRING']}"
    end
  end
end
