# frozen_string_literal: true

require "test_helper"

class BreezyPDF::RenderRequestTest < BreezyTest
  def test_submit
    client_mock = MiniTest::Mock.new
    client_mock.expect(
      :post,
      BreezyPDF::Response.new(OpenStruct.new(code: "200")),
      ["/pdf/public_urls", url_to_render: "blah", metadata: {}]
    )

    request = tested_class.new("blah")
    request.stub(:client, client_mock) do
      assert_kind_of BreezyPDF::Response, request.submit
    end

    assert client_mock.verify
  end
end
