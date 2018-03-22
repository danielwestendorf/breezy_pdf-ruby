# frozen_string_literal: true

module BreezyPDF::PrivateAssets
  # :nodoc
  class HTML
    def initialize(base_url, html_fragment)
      @base_url      = base_url
      @html_fragment = html_fragment
    end

    def content_type
      "text/html"
    end

    def filename
      @filename ||= "#{SecureRandom.hex}.html"
    end

    def file_path
      file.path
    end

    def metadata
      @metadata ||= BreezyPDF.extract_metadata ? Hash[*meta_tags] : {}
    end

    private

    def file
      @file ||= Tempfile.new(filename).tap do |f|
        f.write(html_fragment)
        f.rewind
      end
    end

    def html_fragment
      if BreezyPDF.upload_assets
        BreezyPDF::PublicizeHTML.new(@base_url, @html_fragment).public_fragment
      else
        @html_fragment
      end
    end

    def parsed_document
      @parsed_document ||= Nokogiri::HTML(@html_fragment)
    end

    def meta_tags
      @meta_tags ||= parsed_document.css(%(meta[name^="breezy-pdf-"])).collect do |tag|
        [tag["name"].gsub(/^breezy\-pdf\-/, ""), tag["content"]]
      end.flatten
    end
  end
end
