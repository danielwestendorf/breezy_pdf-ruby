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
      BreezyPDF.filter_elements_selectors.each do |selector|
        BreezyPDF.logger.info("[BreezyPDF] Stripping out elements matching selector `#{selector}`")
        parsed_document.css(selector).each(&:remove)
      end
    end

    def parsed_document
      @parsed_document ||= Nokogiri::HTML(@html_fragment)
    end
  end
end
