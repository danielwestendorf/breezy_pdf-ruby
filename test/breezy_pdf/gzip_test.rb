# frozen_string_literal: true

require "test_helper"

class BreezyPDF::GzipTest < Minitest::Test
  def test_compress_should_return_gzipped_string_by_compression_level
    source_string = "Hello World" * 100

    gzipped_by_speed = BreezyPDF::Gzip.compress(source_string, Zlib::BEST_SPEED)
    assert_equal 1, Zlib::GzipReader.new(StringIO.new(gzipped_by_speed)).level

    gzipped_by_best_compression = BreezyPDF::Gzip.compress(source_string, Zlib::BEST_COMPRESSION)
    assert_equal 9, Zlib::GzipReader.new(StringIO.new(gzipped_by_best_compression)).level

    assert_equal true, (gzipped_by_best_compression.bytesize < gzipped_by_speed.bytesize)
  end
end
