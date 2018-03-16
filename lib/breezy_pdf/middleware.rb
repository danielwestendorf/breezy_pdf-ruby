module BreezyPDF
  class Middleware
    def initialize(app, options={})
      @app = app
    end

    def call(env)
      Interceptor.new(@app, env).intercept!
    end
  end
end
