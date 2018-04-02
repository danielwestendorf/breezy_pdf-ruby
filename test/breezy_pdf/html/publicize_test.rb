# frozen_string_literal: true

require "test_helper"

class BreezyPDF::HTML::PublicizeTest < BreezyTest
  def fragment
    @fragment ||= fixture("example.html").read
  end

  def base_url
    @base_url ||= "http://localhost:3000"
  end

  def mock_expectations
    [
      img_mock_expectation,
      js_mock_expectation,
      css_mock_expectation
    ]
  end

  def css_mock_expectation
    [
      OpenStruct.new(filename: "file.css", content_type: "text/css", file_path: "/tmp/file.css"),
      [base_url, "/file.css"]
    ]
  end

  def img_mock_expectation
    [
      OpenStruct.new(filename: "file.png", content_type: "text/png", file_path: "/tmp/file.png"),
      [base_url, "/file.png"]
    ]
  end

  def js_mock_expectation
    [
      OpenStruct.new(filename: "file.js", content_type: "text/javascript", file_path: "/tmp/file.js"),
      [base_url, "/file.js"]
    ]
  end

  def setup
    @asset_mock  = MiniTest::Mock.new
    @upload_mock = MiniTest::Mock.new

    mock_expectations.each.with_index do |expectation, i|
      @asset_mock.expect(:new, *expectation)

      result     = expectation[0]
      public_url = "https://breezypdf.com/#{result.filename}"

      @upload_mock.expect(
        :new,
        OpenStruct.new(public_url: public_url, id: i.to_s),
        [result.filename, result.content_type, result.file_path]
      )
    end

    BreezyPDF::Resources.stub_const(:Asset, @asset_mock) do
      BreezyPDF::Uploads.stub_const(:Base, @upload_mock) do
        instance         = tested_class.new(base_url, fragment)

        @public_fragment = instance.public_fragment
        @upload_ids      = instance.upload_ids
        @result_doc      = Nokogiri::HTML(@public_fragment)
      end
    end
  end

  def teardown
    assert @asset_mock.verify
    assert @upload_mock.verify
  end

  def test_link_tags_are_replaced
    assert_equal 3, @result_doc.css(%(link)).length
    assert_equal 1, @result_doc.css(%(link[href^="https://breezypdf.com"])).length
  end

  def test_script_tags_are_replaced
    assert_equal 3, @result_doc.css(%(script)).length
    assert_equal 1, @result_doc.css(%(script[src^="https://breezypdf.com"])).length
  end

  def test_img_tags_are_replaced
    assert_equal 2, @result_doc.css(%(img)).length
    assert_equal 1, @result_doc.css(%(img[src^="https://breezypdf.com"])).length
  end

  def test_upload_ids
    assert_equal %w[0 1 2], @upload_ids
  end
end
