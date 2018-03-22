# frozen_string_literal: true

require "test_helper"

class BreezyPDF::Intercept::PublicUrlTest < BreezyTest
  def env
    {
      "REQUEST_URI"     => "/thing.pdf",
      "REQUEST_METHOD"  => "GET",
      "rack.url_scheme" => "https",
      "SERVER_NAME"     => "example.com",
      "SERVER_PORT"     => "443",
      "PATH_INFO"       => "/thing.pdf",
      "QUERY_STRING"    => "a=b"
    }
  end

  def test_redirects_to_download_url
    response = OpenStruct.new(code: "201", body: { download_url: "abc" }.to_json)

    mock_submit = MiniTest::Mock.new
    mock_submit.expect(:submit, response)

    mock_request = MiniTest::Mock.new
    mock_request.expect(:new, mock_submit, ["https://example.com:443/thing?a=b"])

    BreezyPDF.stub_const(:RenderRequest, mock_request) do
      tested_class.new(nil, env).call
    end

    assert mock_request.verify
    assert mock_submit.verify
  end
end
