# frozen_string_literal: true

require "test_helper"

class BreezyPDFTest < BreezyTest
  def test_that_it_has_a_version_number
    refute_nil BreezyPDF::VERSION
  end

  def test_default_values
    refute_nil BreezyPDF.base_url
  end

  def test_setup_block
    BreezyPDF.setup do |config|
      config.secret_api_key = "123"
    end

    assert_equal(BreezyPDF.secret_api_key, "123")
    refute_nil BreezyPDF.base_url
  end
end
