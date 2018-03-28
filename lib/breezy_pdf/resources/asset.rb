# frozen_string_literal: true

module BreezyPDF::Resources
  # :nodoc
  class Asset
    def initialize(base_url, asset_path_or_url)
      @base_url          = base_url
      @asset_path_or_url = asset_path_or_url
    end

    def content_type
      io_object.content_type
    end

    def filename
      @filename ||= URI(asset_url).path.split("/").last
    end

    def file_path
      file.path
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

    def io_object
      @io_object ||= open(asset_url)
    end

    def asset_url
      @asset_url ||= if URI(@asset_path_or_url).host
                       @asset_path_or_url
                     else
                       "#{@base_url}#{@asset_path_or_url}"
                     end
    end
  end
end
