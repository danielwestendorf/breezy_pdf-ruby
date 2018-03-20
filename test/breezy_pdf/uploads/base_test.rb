# frozen_string_literal: true

require "test_helper"

class BreezyPDF::Uploads::BaseTest < BreezyTest
  def test_public_url
    resource = {
      "presigned_upload_url" =>    "https://example.com/upload",
      "presigned_upload_fields" => {},
      "resource_url" =>            "/api/uploads/123",
      "presigned_url" =>           "https://example.com/123/image.png",
      "id" =>                      "123"
    }

    instance = tested_class.new("image.png", "image/png", fixture("file.png").path)

    client_mock = MiniTest::Mock.new
    # Presign HTTP Request
    client_mock.expect(
      :post, OpenStruct.new(resource),
      ["/uploads", filename: "image.png", size: fixture("file.png").size, content_type: "image/png"]
    )
    # Complete HTTP Request
    client_mock.expect(:put, true, ["/uploads/#{resource["id"]}", {}])

    # Upload HTTP Request
    request_mock = MiniTest::Mock.new
    request_mock.expect(:request, OpenStruct.new(code: "204"))

    upload_mock = MiniTest::Mock.new
    upload_mock.expect(:new, request_mock, ["example.com", 443])
    upload_mock.expect(:use_ssl=, true, [true])

    instance.stub(:upload!, upload_mock) do
      instance.stub(:client, client_mock) do
        assert_equal resource["presigned_url"], instance.public_url
      end
    end
  end
end
