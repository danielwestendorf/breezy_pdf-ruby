# frozen_string_literal: true

module BreezyPDF
  # :nodoc
  class Middleware
    def initialize(app, _options = {})
      @app = app
    end

    def call(env)
      Interceptor.new(@app, env).intercept!
    end
  end
end
