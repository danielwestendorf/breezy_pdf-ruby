# frozen_string_literal: true

module BreezyPDF::Intercept
  # :nodoc
  class Base
    attr_reader :app, :env

    def initialize(app, env)
      @app = app
      @env = env
    end
  end
end
