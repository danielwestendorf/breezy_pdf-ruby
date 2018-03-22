# frozen_string_literal: true

require "test_helper"

class BreezyPDF::PrivateAssets::AssetTest < BreezyTest
  def setup
    @file_mock = MiniTest::Mock.new
    @file_mock.expect(:path, "abc")
    @file_mock.expect(:content_type, "xyz")
  end

  def test_content_type
    instance = tested_class.new("", "")
    instance.stub(:open, @file_mock) do
      assert_equal "xyz", instance.content_type
    end
  end

  def test_filename
    assert_equal "thing.js", tested_class.new("https://example.com", "/blah/thing.js").filename
  end

  def test_file_path
    instance = tested_class.new("", "")
    instance.stub(:open, @file_mock) do
      assert_equal "xyz", instance.content_type
    end
  end
  # def test_filename
  #   instance = tested_class.new("")
  #   assert_equal instance.filename, instance.filename
  # end

  # def test_file_path
  #   assert_match(/\.html/, tested_class.new("").file_path)
  # end

  # def test_file_contents
  #   contents = "<h1>Hey!</h1>"
  #   instance = tested_class.new(contents)

  #   assert_equal contents, File.read(instance.file_path)
  # end
end
