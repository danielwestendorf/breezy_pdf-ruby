# frozen_string_literal: true

require "test_helper"

class BreezyPDF::Intercept::PrivateUrlTest < BreezyTest
  def app_response
    [200, {}, [fixture("metadata.html").read]]
  end

  def metadata
    {
      "head" => "2",
      "alt"  => "3",
      "body" => "4"
    }
  end

  def mocks
    mock_public_url = MiniTest::Mock.new
    mock_public_url.expect(:public_url, "xyz")

    mock_upload = MiniTest::Mock.new
    mock_upload.expect(:new, mock_public_url, [/\.html$/, "text/html", String])

    response = OpenStruct.new(download_url: "abc")

    mock_submit = MiniTest::Mock.new
    mock_submit.expect(:submit, response)

    mock_request = MiniTest::Mock.new
    mock_request.expect(:new, mock_submit, ["xyz", metadata])

    mock_app = MiniTest::Mock.new
    mock_app.expect(:call, app_response, [{ "PATH_INFO" => "/xyz", "HTTP_ACCEPT" => "text/html" }])

    [mock_public_url, mock_upload, mock_request, mock_submit, mock_app]
  end

  def test_redirects_to_download_url
    mock_public_url, mock_upload, mock_request, mock_submit, mock_app = mocks

    BreezyPDF::Uploads.stub_const(:Base, mock_upload) do
      BreezyPDF.stub_const(:RenderRequest, mock_request) do
        status, headers, _body = tested_class.new(mock_app, "PATH_INFO" => "/xyz.pdf").call

        assert_equal 302, status
        assert_equal "abc", headers["Location"]
      end
    end

    assert mock_public_url.verify
    assert mock_upload.verify
    assert mock_request.verify
    assert mock_submit.verify
    assert mock_app.verify
  end

  def test_non_2XX_app_response
    mock_app = MiniTest::Mock.new
    mock_app.expect(:call, [301, { "Location" => "/xyz" }, [""]], [{ "PATH_INFO" => "/xyz", "HTTP_ACCEPT" => "text/html" }])

    status, headers, _body = tested_class.new(mock_app, "PATH_INFO" => "/xyz.pdf").call

    assert_equal 301, status
    assert_equal "/xyz", headers["Location"]

    assert mock_app.verify
  end
end
