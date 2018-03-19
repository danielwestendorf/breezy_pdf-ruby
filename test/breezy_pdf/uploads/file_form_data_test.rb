# frozen_string_literal: true

require "test_helper"

class BreezyPDF::Uploads::FileFormDataTest < BreezyTest
  def test_boundary
    instance = tested_class.new(nil, nil, nil, nil)

    assert_equal instance.boundary, instance.boundary
  end

  def test_field_data
    fields = { a: "b", c: "d" }

    instance = tested_class.new(fields, nil, nil, fixture("file.png"))

    fields.each do |k, v|
      assert_match %(Content-Disposition: form-data; name="#{k}"\r\n\r\n#{v}\r\n), instance.data
    end
  end

  def test_file_data
    instance = tested_class.new({}, "image/png", "ex.png", fixture("file.png"))
    file_data = [
      "--#{instance.boundary}\r\n",
      %(Content-Disposition: form-data; name="file"; filename="ex.png"\r\n),
      "Content-Type: image/png\r\n\r\n",
      BreezyPDF::Gzip.compress(fixture("file.png").read)
    ]
    assert_match file_data.join, instance.data
  end

  def test_closing_data
    instance = tested_class.new({}, nil, nil, fixture("file.png"))
    closing = [
      "--#{instance.boundary}\r\n",
      %(Content-Disposition: form-data; name="submit"\r\n\r\n),
      %(Upload) + "\r\n",
      "--#{instance.boundary}--"
    ]
    assert_match closing.join, instance.data
  end
end
