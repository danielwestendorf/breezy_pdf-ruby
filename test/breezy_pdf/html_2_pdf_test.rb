# frozen_string_literal: true

require "test_helper"

class BreezyPDF::HTML2PDFTest < BreezyTest
  def asset_host
    "http://example.com"
  end

  def html
    "html"
  end

  def mocks
    mock_html_response = MiniTest::Mock.new
    mock_html_response.expect(:filename, "file.pdf")
    mock_html_response.expect(:content_type, "text/html")
    mock_html_response.expect(:file_path, "abc")
    mock_html_response.expect(:metadata, a: 1)

    mock_html_asset = MiniTest::Mock.new
    mock_html_asset.expect(:new, mock_html_response, [asset_host, html])

    mock_upload = MiniTest::Mock.new
    mock_upload.expect(:new, OpenStruct.new(public_url: "public.html"), ["file.pdf", "text/html", "abc"])

    mock_render_result = MiniTest::Mock.new
    mock_render_result.expect(:submit, OpenStruct.new(download_url: "file.pdf"))

    mock_render_request = MiniTest::Mock.new
    mock_render_request.expect(:new, mock_render_result, ["public.html", { a: 1 }])

    [mock_html_response, mock_html_asset, mock_upload, mock_render_result, mock_render_request]
  end

  def test_to_file
    mock_html_response, mock_html_asset, mock_upload, mock_render_result, mock_render_request = mocks

    file_mock = MiniTest::Mock.new
    file_mock.expect(:is_a?, false, [StringIO])

    BreezyPDF.stub_const(:RenderRequest, mock_render_request) do
      BreezyPDF::Uploads.stub_const(:Base, mock_upload) do
        BreezyPDF::PrivateAssets.stub_const(:HTML, mock_html_asset) do
          instance = tested_class.new(asset_host, html)

          instance.stub(:open, file_mock) do
            assert_equal file_mock.object_id, instance.to_file.object_id
          end
        end
      end
    end

    assert mock_html_response.verify
    assert mock_html_asset.verify
    assert mock_upload.verify
    assert mock_render_result.verify
    assert mock_render_request.verify

    file_mock.verify
  end

  def test_to_url
    mock_html_response, mock_html_asset, mock_upload, mock_render_result, mock_render_request = mocks

    BreezyPDF.stub_const(:RenderRequest, mock_render_request) do
      BreezyPDF::Uploads.stub_const(:Base, mock_upload) do
        BreezyPDF::PrivateAssets.stub_const(:HTML, mock_html_asset) do
          instance = tested_class.new(asset_host, html)

          assert_equal "file.pdf", instance.to_url
        end
      end
    end

    assert mock_html_response.verify
    assert mock_html_asset.verify
    assert mock_upload.verify
    assert mock_render_result.verify
    assert mock_render_request.verify
  end
end
