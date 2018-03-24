# frozen_string_literal: true

require "test_helper"

class BreezyPDF::PrivateAssets::HTMLTest < BreezyTest
  def teardown
    BreezyPDF.upload_assets = true
    BreezyPDF.extract_metadata = true
  end

  def test_content_type
    assert_equal "text/html", tested_class.new("", "").content_type
  end

  def test_filename
    instance = tested_class.new("", "")
    assert_equal instance.filename, instance.filename
  end

  def test_file_path
    assert_match(/\.html/, tested_class.new("", "").file_path)
  end

  def test_file_contents_with_uploading_of_assets_turned_off
    BreezyPDF.upload_assets = false

    contents = "<h1>Hey!</h1>"
    instance = tested_class.new("", contents)

    assert_equal contents, File.read(instance.file_path)
  end

  def test_metadata_when_enabled
    BreezyPDF.extract_metadata = true

    contents = fixture("metadata.html").read
    instance = tested_class.new("", contents)

    assert_equal "2", instance.metadata["head"]
    assert_equal "3", instance.metadata["alt"]
    assert_equal "4", instance.metadata["body"]
  end

  def test_metadata_when_disabled
    BreezyPDF.extract_metadata = false

    contents = fixture("metadata.html").read
    instance = tested_class.new("", contents)

    assert_nil instance.metadata["head"]
    assert_nil instance.metadata["alt"]
    assert_nil instance.metadata["body"]
  end

  def test_file_contents_with_uploading_of_assets_turned_on
    BreezyPDF.upload_assets = true

    contents = "<h1>Hey!</h1>"
    host     = "http://example.com"

    publicize_mock = MiniTest::Mock.new
    publicize_mock.expect(
      :new, OpenStruct.new(public_fragment: contents), [host, contents]
    )

    BreezyPDF::HTML.stub_const(:Publicize, publicize_mock) do
      instance = tested_class.new(host, contents)
      assert_equal contents, File.read(instance.file_path)
    end

    assert publicize_mock.verify
  end
end
