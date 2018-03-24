# frozen_string_literal: true

module BreezyPDF::HTML
  # Replace assets with uploaded URL's
  class Strip
    def initialize(html_fragment)
      @html_fragment = html_fragment
    end

    def stripped_fragment
      @stripped_fragment ||= parsed_document.tap do
        strip!
      end.to_html
    end

    private

    def strip!
      parsed_document.css(filter_elements_selector).each do |filtered_element|
        filtered_element.remove
      end
    end

    def parsed_document
      @parsed_document ||= Nokogiri::HTML(@html_fragment)
    end
  end
end
