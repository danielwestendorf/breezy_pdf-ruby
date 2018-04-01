# frozen_string_literal: true

require "test_helper"

class BreezyPDF::Cache::InMemoryTest < BreezyTest
  def set_test
    assert tested_class.new.set("a", "b")
  end

  def get_test
    instance = tested_class.new
    instance.set("a", "b")

    assert_equal "b", instance.get("a")
  end

  def test_fetch_value_already_set
    instance = tested_class.new
    instance.set("a", "b")

    assert_equal "b", instance.fetch("a")
  end

  def test_fetch_value_not_set
    instance = tested_class.new

    assert_nil instance.get("a")

    returned_value = instance.fetch("a") do
      "b"
    end

    assert_equal "b", returned_value
    assert_equal "b", instance.get("a")
  end

  def test_remove_last_accessed!
    instance = tested_class.new

    1001.times do |i|
      instance.set(i, i)
    end

    assert_nil instance.get(0)
    assert_equal 1, instance.get(1)
  end
end
