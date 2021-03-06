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
                    f.write io_object.tap(&:rewind).read
                    f.flush
                  end
                else
                  io_object
                end
    end

    def io_object
      @io_object ||= download_asset_from_url
    end

    def download_asset_from_url
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      asset_object = open(asset_url)
      timing = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time

      BreezyPDF.logger.info("[BreezyPDF] Downloading #{filename} took `#{timing} seconds`")

      asset_object
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
