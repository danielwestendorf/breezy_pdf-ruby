# frozen_string_literal: true

require "zlib"
require "stringio"

module BreezyPDF
  # https://github.com/rails/rails/blob/master/activesupport/lib/active_support/gzip.rb
  module Gzip
    # :nodoc
    class Stream < StringIO
      def initialize(*)
        super
        set_encoding "BINARY"
      end

      def close
        rewind
      end
    end

    # Compresses a string using gzip.
    def self.compress(source, level = Zlib::DEFAULT_COMPRESSION, strategy = Zlib::DEFAULT_STRATEGY)
      output = Stream.new
      gz = Zlib::GzipWriter.new(output, level, strategy)
      gz.write(source)
      gz.close
      output.string
    end
  end
end
