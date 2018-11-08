# frozen_string_literal: true

require "test_helper"

class BreezyPDF::ClientTest < BreezyTest
  def setup
    BreezyPDF.setup do |config|
      config.secret_api_key = "123"
    end
  end

  def test_post
    body = { a: 1 }
    http_mock = MiniTest::Mock.new
    request_mock = MiniTest::Mock.new
    request_mock.expect(:body=, true, [body.to_json])

    http_mock.expect(:tap, http_mock)
    http_mock.expect(:request, OpenStruct.new(code: "201"), [request_mock])

    Net::HTTP.stub(:new, http_mock) do
      Net::HTTP::Post.stub(:new, request_mock) do
        tested_class.new.post("/test", body)
      end
    end

    assert http_mock.verify
    assert request_mock.verify
  end

  def test_put
    body = { a: 1 }
    http_mock = MiniTest::Mock.new
    request_mock = MiniTest::Mock.new
    request_mock.expect(:body=, true, [body.to_json])

    http_mock.expect(:tap, http_mock)
    http_mock.expect(:request, OpenStruct.new(code: "201"), [request_mock])

    Net::HTTP.stub(:new, http_mock) do
      Net::HTTP::Put.stub(:new, request_mock) do
        tested_class.new.put("/test", body)
      end
    end

    assert http_mock.verify
    assert request_mock.verify
  end

  def test_no_secret_api_key
    BreezyPDF.setup do |config|
      config.secret_api_key = nil
    end

    assert_raises(BreezyPDF::AuthError) do
      tested_class.new.put("/test", {})
    end
  end
end
