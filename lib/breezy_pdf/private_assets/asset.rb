# frozen_string_literal: true

module BreezyPDF::PrivateAssets
  # :nodoc
  class Asset
    def initialize(base_url, asset_path_or_url)
      @base_url          = base_url
      @asset_path_or_url = asset_path_or_url
    end

    def content_type
      file.content_type
    end

    def filename
      @filename ||= URI(asset_url).path.split("/").last
    end

    def file_path
      file.path
    end

    private

    def file
      @file ||= open(asset_url)
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
