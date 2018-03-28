# frozen_string_literal: true

module BreezyPDF
  # :nodoc
  module Uploads
    autoload :Base,         "breezy_pdf/uploads/base"
    autoload :FileFormData, "breezy_pdf/uploads/file_form_data"

    PresignError    = Class.new(BreezyPDFError)
    UploadError     = Class.new(BreezyPDFError)
    CompletionError = Class.new(BreezyPDFError)
  end
end
