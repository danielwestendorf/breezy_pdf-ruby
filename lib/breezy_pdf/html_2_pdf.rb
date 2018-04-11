# frozen_string_literal: true

module BreezyPDF
  # Transform an HTML slug to a PDF
  # Access it's URL or download it locally and access it as a Tempfile
  class HTML2PDF
    def initialize(asset_host, html_string, metadata = {})
      @asset_host  = asset_host
      @html_string = html_string
      @metadata    = metadata
    end

    def to_url
      url
    end

    def to_file
      file
    end

    private

    def file
      @file ||= if io_object.is_a?(StringIO)
                  Tempfile.new.tap do |f|
                    f.write io_object.to_s
                  end
                else
                  io_object
                end
    end

    def url
      @url ||= BreezyPDF::RenderRequest.new(public_url, combined_metadata).submit.download_url
    end

    def combined_metadata
      @combined_metadata ||= BreezyPDF.default_metadata.merge(@metadata).merge(html_private_asset.metadata)
    end

    def io_object
      @io_object ||= open(url)
    end

    def html_private_asset
      @html_private_asset ||= BreezyPDF::Resources::HTML.new(@asset_host, @html_string)
    end

    def public_url
      @public_url ||= BreezyPDF::Uploads::Base.new(
        html_private_asset.filename, html_private_asset.content_type, html_private_asset.file_path
      ).public_url
    end
  end
end
