# frozen_string_literal: true

module BreezyPDF::Cache
  # Null cache store for assets. Doesn't actually store anything.
  class Null
    def write(_key, _value, _opts = {})
      true
    end

    def read(key); end

    def fetch(_key, _opts = {})
      yield if block_given?
    end
  end
end
