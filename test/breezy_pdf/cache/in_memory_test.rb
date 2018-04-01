# frozen_string_literal: true

require "test_helper"

class BreezyPDF::Cache::InMemoryTest < BreezyTest
  def write_test
    assert tested_class.new.write("a", "b")
  end

  def read_test
    instance = tested_class.new
    instance.write("a", "b")

    assert_equal "b", instance.read("a")
  end

  def test_fetch_value_already_write
    instance = tested_class.new
    instance.write("a", "b")

    assert_equal "b", instance.fetch("a")
  end

  def test_fetch_value_not_writen
    instance = tested_class.new

    assert_nil instance.read("a")

    returned_value = instance.fetch("a") do
      "b"
    end

    assert_equal "b", returned_value
    assert_equal "b", instance.read("a")
  end

  def test_remove_last_accessed!
    instance = tested_class.new

    1001.times do |i|
      instance.write(i, i)
    end

    assert_nil instance.read(0)
    assert_equal 1, instance.read(1)
  end

  def test_key_expiration
    instance = tested_class.new
    instance.write("a", "b", expires_in: 60)

    Time.stub(:now, Time.now + 60.1) do
      assert_nil instance.read("a")
    end

    assert_nil instance.read("a") # it should have been deleted from the map
  end
end
