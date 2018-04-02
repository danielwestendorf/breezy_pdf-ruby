# frozen_string_literal: true

module BreezyPDF::Resources
  # :nodoc
  class HTML
    def initialize(base_url, html_fragment)
      @base_url      = base_url
      @html_fragment = html_fragment
      @upload_ids    = []
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

    def upload_ids
      modified_html_fragment

      @upload_ids
    end

    private

    def file
      @file ||= Tempfile.new(filename).tap do |f|
        f.write(modified_html_fragment)
        f.rewind
      end
    end

    def modified_html_fragment
      @modified_html_fragment ||= modify_html_fragment!
    end

    def modify_html_fragment!
      if BreezyPDF.filter_elements
        @html_fragment = BreezyPDF::HTML::Strip.new(
          @html_fragment
        ).stripped_fragment
      end

      if BreezyPDF.upload_assets
        publiciser = BreezyPDF::HTML::Publicize.new(
          @base_url, @html_fragment
        )
        @upload_ids    = publiciser.upload_ids
        @html_fragment = publiciser.public_fragment
      end

      @html_fragment
    end

    def parsed_document
      @parsed_document ||= Nokogiri::HTML(modified_html_fragment)
    end

    def meta_tags
      @meta_tags ||= parsed_document.css(%(meta[name^="breezy-pdf-"])).collect do |tag|
        [tag["name"].gsub(/^breezy\-pdf\-/, ""), tag["content"]]
      end.flatten
    end
  end
end
