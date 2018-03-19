# frozen_string_literal: true

require "breezy_pdf/util"
require "breezy_pdf/gzip"

# :nodoc
module BreezyPDF
  extend BreezyPDF::Util

  autoload :VERSION,     "breezy_pdf/version"
  autoload :Request,     "breezy_pdf/request"
  autoload :Client,      "breezy_pdf/client"
  autoload :Response,    "breezy_pdf/response"
  autoload :Middleware,  "breezy_pdf/middleware"
  autoload :Interceptor, "breezy_pdf/interceptor"
  autoload :Uploads,     "breezy_pdf/uploads"

  BreezyPDFError = Class.new(StandardError)

  mattr_accessor :secret_api_key
  @@secret_api_key = nil

  mattr_accessor :upload_private_assets
  @@upload_private_assets = false

  mattr_accessor :base_url
  @@base_url = "https://www.breezypdf.com/api"

  mattr_accessor :middleware_path_matchers
  @@middleware_path_matchers = [/\.pdf$/]

  def self.setup
    yield self
  end
end
