# frozen_string_literal: true

require "test_helper"

class BreezyPDF::Cache::NullTest < BreezyTest
  def write_test
    assert tested_class.new.write("a", "b")
  end

  def read_test
    instance = tested_class.new
    instance.write("a", "b")

    assert_nil instance.read("a")
  end

  def test_fetch_value_already_write
    instance = tested_class.new
    instance.write("a", "b")

    assert_nil instance.fetch("a")
  end

  def test_fetch_value_not_write
    instance = tested_class.new

    returned_value = instance.fetch("a") do
      "b"
    end

    assert_equal "b", returned_value
  end
end
