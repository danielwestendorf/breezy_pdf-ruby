# frozen_string_literal: true

module BreezyPDF::HTML
  # Replace assets with uploaded URL's
  class Strip
    def initialize(html_fragment)
      @html_fragment = html_fragment
      @start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def stripped_fragment
      @stripped_fragment ||= parsed_document.tap do
        strip!
        BreezyPDF.logger.info("[BreezyPDF] Stripped out elements in `#{timing} seconds`")
      end.to_html
    end

    def timing
      @timing ||= Process.clock_gettime(Process::CLOCK_MONOTONIC) - @start_time
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
