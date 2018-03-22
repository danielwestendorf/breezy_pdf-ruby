# frozen_string_literal: true

module BreezyPDF
  # Replace assets with uploaded URL's
  class PublicizeHTML
    def initialize(base_url, html_fragment)
      @base_url      = base_url
      @html_fragment = html_fragment
    end

    def public_fragment
      @public_fragment ||= parsed_document.tap do
        publicize!
      end.to_html
    end

    private

    def publicize!
      BreezyPDF.asset_selectors.each do |selector|
        parsed_document.css(selector).each do |asset_element|
          replace_asset_elements_matched_paths(asset_element)
        end
      end
    end

    def parsed_document
      @parsed_document ||= Nokogiri::HTML(@html_fragment)
    end

    def replace_asset_elements_matched_paths(asset_element)
      BreezyPDF.asset_path_matchers.each do |attr, matcher|
        attr_value = asset_element[attr.to_s]
        replace_asset_element_attr(asset_element, attr.to_s) if attr_value && attr_value.match?(matcher)
      end
    end

    def replace_asset_element_attr(asset_element, attr)
      asset = BreezyPDF::PrivateAssets::Asset.new(@base_url, asset_element[attr])

      asset_element[attr] = BreezyPDF::Uploads::Base.new(
        asset.filename, asset.content_type, asset.file_path
      ).public_url
    end
  end
end
