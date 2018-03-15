require "test_helper"
require "net/http"

class BreezyPDF::ClientTest < Minitest::Test
  def test_post
    body = { a: 1 }
    http_mock = MiniTest::Mock.new
    request_mock = MiniTest::Mock.new
    request_mock.expect(:body=, true, [body.to_json])

    http_mock.expect(:request, true, [request_mock])

    Net::HTTP.stub(:new, http_mock) do
      Net::HTTP::Post.stub(:new, request_mock) do
        BreezyPDF::Client.new.post("/test", body)
      end
    end

    assert http_mock.verify
    assert request_mock.verify
  end
end
