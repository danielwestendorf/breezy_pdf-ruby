# frozen_string_literal: true

require "test_helper"

class BreezyPDF::InterceptorTest < Minitest::Test
  def test_non_matching_uri
    env = {
      "REQUEST_URI"    => "/thing",
      "REQUEST_METHOD" => "GET"
    }

    app = MiniTest::Mock.new
    app.expect(:call, true, [env])

    BreezyPDF::Interceptor.new(app, env).intercept!

    assert app.verify
  end

  def test_non_matching_method
    env = {
      "REQUEST_METHOD" => "POST"
    }

    app = MiniTest::Mock.new
    app.expect(:call, true, [env])

    BreezyPDF::Interceptor.new(app, env).intercept!

    assert app.verify
  end

  def test_matching_uri_and_method
    env = {
      "REQUEST_URI"     => "/thing.pdf",
      "REQUEST_METHOD"  => "GET",
      "rack.url_scheme" => "https",
      "SERVER_NAME"     => "example.com",
      "SERVER_PORT"     => "443",
      "PATH_INFO"       => "/thing.pdf",
      "QUERY_STRING"    => "a=b"
    }

    response = OpenStruct.new(code: "201", body: { download_url: "abc" }.to_json)

    mock_submit = MiniTest::Mock.new
    mock_submit.expect(:submit, response)

    mock_request = MiniTest::Mock.new
    mock_request.expect(:new, mock_submit, ["https://example.com:443/thing.pdf?a=b"])

    BreezyPDF.stub_const(:Request, mock_request) do
      BreezyPDF::Interceptor.new(nil, env).intercept!
    end

    assert mock_request.verify
    assert mock_submit.verify
  end
end
