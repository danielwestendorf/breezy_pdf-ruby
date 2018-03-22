# frozen_string_literal: true

module BreezyPDF
  # :nodoc
  module Intercept
    autoload :Base,       "breezy_pdf/intercept/base"
    autoload :PublicUrl,  "breezy_pdf/intercept/public_url"
    autoload :PrivateUrl, "breezy_pdf/intercept/private_url"
  end
end
