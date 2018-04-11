# frozen_string_literal: true

require "test_helper"

class BreezyPDF::Intercept::PublicUrlTest < BreezyTest
  def env
    {
      "REQUEST_URI"     => "/thing.pdf",
      "REQUEST_METHOD"  => "GET",
      "rack.url_scheme" => "https",
      "SERVER_NAME"     => "example.com",
      "SERVER_PORT"     => "3000",
      "PATH_INFO"       => "/thing.pdf",
      "QUERY_STRING"    => "a=b"
    }
  end

  def mocks
    response = OpenStruct.new(code: "201", body: { download_url: "abc" }.to_json)

    mock_submit = MiniTest::Mock.new
    mock_submit.expect(:submit, response)

    mock_request = MiniTest::Mock.new
    [mock_request, mock_submit]
  end

  def test_redirects_to_download_url
    mock_request, mock_submit = mocks

    metadata = BreezyPDF.default_metadata.merge(
      "requested_url" => "https://example.com:3000/thing.pdf?a=b", "rendered_url" => "https://example.com:3000/thing?a=b"
    )

    mock_request.expect(:new, mock_submit, ["https://example.com:3000/thing?a=b", metadata])

    BreezyPDF.stub_const(:RenderRequest, mock_request) do
      tested_class.new(nil, env).call
    end

    assert mock_request.verify
    assert mock_submit.verify
  end

  def test_redirects_to_download_url_with_normal_port
    mock_request, mock_submit = mocks

    metadata =  BreezyPDF.default_metadata.merge(
      "requested_url" => "https://example.com/thing.pdf?a=b", "rendered_url" => "https://example.com/thing?a=b"
    )

    mock_request.expect(:new, mock_submit, ["https://example.com/thing?a=b", metadata])

    BreezyPDF.stub_const(:RenderRequest, mock_request) do
      tested_class.new(nil, env.tap { |h| h["SERVER_PORT"] = 443 }).call
    end

    assert mock_request.verify
    assert mock_submit.verify
  end
end
