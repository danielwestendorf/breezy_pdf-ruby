# frozen_string_literal: true

require "uri"
require "net/http"
require "json"
require "tempfile"
require "securerandom"
require "zlib"
require "stringio"
require "open-uri"

require "nokogiri"
require "concurrent"

require "breezy_pdf/util"
require "breezy_pdf/gzip"

# :nodoc
module BreezyPDF
  extend BreezyPDF::Util

  autoload :VERSION,       "breezy_pdf/version"
  autoload :RenderRequest, "breezy_pdf/render_request"
  autoload :Client,        "breezy_pdf/client"
  autoload :Response,      "breezy_pdf/response"
  autoload :Middleware,    "breezy_pdf/middleware"
  autoload :Interceptor,   "breezy_pdf/interceptor"
  autoload :Uploads,       "breezy_pdf/uploads"
  autoload :Intercept,     "breezy_pdf/intercept"
  autoload :PrivateAssets, "breezy_pdf/private_assets"
  autoload :HTML,          "breezy_pdf/html"

  BreezyPDFError = Class.new(StandardError)

  mattr_accessor :secret_api_key
  @@secret_api_key = nil

  mattr_accessor :base_url
  @@base_url = "https://breezypdf.com/api"

  mattr_accessor :middleware_path_matchers
  @@middleware_path_matchers = [/\.pdf$/]

  mattr_accessor :treat_urls_as_private
  @@treat_urls_as_private = true

  mattr_accessor :upload_assets
  @@upload_assets = true

  mattr_accessor :asset_selectors
  @@asset_selectors = %w(img script link[rel="stylesheet"])

  mattr_accessor :asset_path_matchers
  @@asset_path_matchers = {
    href: %r{^\/\w+},
    src:  %r{^\/\w+}
  }

  mattr_accessor :extract_metadata
  @@extract_metadata = true

  mattr_accessor :threads
  @@threads = 1

  mattr_accessor :filter_elements
  @@filter_elements = false

  mattr_accessor :filter_elements_selectors
  @@filtered_element_selectors = %w[.breezy-pdf-remove]

  mattr_accessor :logger
  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::FATAL

  def self.setup
    yield self
  end
end
