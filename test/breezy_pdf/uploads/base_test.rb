# frozen_string_literal: true

require "test_helper"

class BreezyPDF::Uploads::BaseTest < BreezyTest
  def resource
    @resource ||= {
      "presigned_upload_url" =>    "https://example.com/upload",
      "presigned_upload_fields" => {},
      "resource_url" =>            "/api/uploads/123",
      "presigned_url" =>           "https://example.com/123/image.png",
      "id" =>                      "123"
    }
  end

  def mocks
    client_mock = MiniTest::Mock.new
    # Presign HTTP Request
    client_mock.expect(
      :post, OpenStruct.new(resource),
      ["/uploads", filename: "image.png", size: fixture("file.png").size, content_type: "image/png"]
    )

    upload_http_mock = MiniTest::Mock.new
    upload_http_mock.expect(:request, OpenStruct.new(code: "204"), [Net::HTTP::Post])

    [client_mock, upload_http_mock]
  end

  def test_public_url
    instance = tested_class.new("image.png", "image/png", fixture("file.png").path)

    client_mock, upload_http_mock = mocks

    instance.stub(:upload_http, upload_http_mock) do
      instance.stub(:client, client_mock) do
        assert_equal resource["presigned_url"], instance.public_url
      end
    end

    assert client_mock.verify
    assert upload_http_mock.verify
  end

  def test_id
    client_mock = MiniTest::Mock.new
    # Presign HTTP Request
    client_mock.expect(
      :post, OpenStruct.new(resource),
      ["/uploads", filename: "image.png", size: fixture("file.png").size, content_type: "image/png"]
    )

    instance = tested_class.new("image.png", "image/png", fixture("file.png").path)

    instance.stub(:client, client_mock) do
      assert_equal resource["id"], instance.id
    end

    assert client_mock.verify
  end
end
