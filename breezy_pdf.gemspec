
# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "breezy_pdf/version"

Gem::Specification.new do |spec|
  spec.name          = "breezy_pdf"
  spec.version       = BreezyPDF::VERSION
  spec.authors       = ["Daniel Westendorf"]
  spec.email         = ["daniel@prowestech.com"]

  spec.summary       = "Ruby client for BreezyPDF.com"
  spec.description   = "Client and Rack Middlware which submits URL's and HTML fragments to " \
                       "be rendered as a PDF"
  spec.homepage      = "https://breezypdf.com"
  spec.license       = "LGPL-3.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "concurrent-ruby", "~> 1"
  spec.add_dependency "nokogiri", "~> 1"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-stub-const", "~> 0.6"
  spec.add_development_dependency "rack-test", "~> 1.1"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rubocop", "0.75.1"
end
