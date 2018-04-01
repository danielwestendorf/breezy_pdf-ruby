# frozen_string_literal: true

module BreezyPDF::Cache
  # Null cache store for assets. Doesn't actually store anything.
  class Null
    def write(key, value, opts = {})
      true
    end

    def read(key); end

    def fetch(key, opts = {}, &blk)
      blk.call if block_given?
    end
  end
end
