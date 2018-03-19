# frozen_string_literal: true

require "test_helper"
require "json"

class BreezyPDF::ResponseTest < Minitest::Test
  def test_success?
    assert BreezyPDF::Response.new(OpenStruct.new(code: "200"))
  end

  def test_failure?
    assert BreezyPDF::Response.new(OpenStruct.new(code: "300"))
  end

  def test_download_url
    fake_http_response = OpenStruct.new(body: { download_url: "abc" }.to_json)
    response = BreezyPDF::Response.new(fake_http_response)
    assert_equal "abc", response.download_url
  end
end
