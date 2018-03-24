# frozen_string_literal: true

require "test_helper"

class BreezyPDF::HTML::StripTest < BreezyTest
  def fragment
    @fragment ||= fixture("strip.html").read
  end

  def setup
    BreezyPDF.filter_elements_selector = %(.breezy-pdf-remove)
  end

  def removes_fitlered_elements
    result = tested_class.new(fragement).stripped_fragment
    doc = Nokogiri::HTML(result)

    assert_equal 0, doc.css(BreezyPDF.filter_elements_selector)
  end
end
