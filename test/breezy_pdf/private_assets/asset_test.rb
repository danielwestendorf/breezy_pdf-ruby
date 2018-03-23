# frozen_string_literal: true

require "test_helper"

class BreezyPDF::PrivateAssets::AssetTest < BreezyTest
  def setup
    @file_mock = MiniTest::Mock.new
    @file_mock.expect(:path, "abc")
    @file_mock.expect(:content_type, "xyz")
    @file_mock.expect(:is_a?, false, [StringIO])
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
      assert_equal "abc", instance.file_path
    end
  end

  def test_file_path_with_string_io_object
    instance = tested_class.new("", "")
    instance.stub(:open, StringIO.new("bob")) do
      assert_match %r{\/\w+\/}, instance.file_path
    end
  end
end
