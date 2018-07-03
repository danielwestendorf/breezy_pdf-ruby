# frozen_string_literal: true

require "test_helper"

class BreezyPDF::Intercept::BaseTest < BreezyTest
  def test_forwared_scheme
    app = proc {}
    env = { "HTTP_X_FORWARDED_SCHEME" => "https", "SERVER_NAME" => "example.com", "SERVER_PORT" => 443 }
    base_url = BreezyPDF::Intercept::Base.new(app, env).send(:base_url)

    assert_equal("https://example.com", base_url)
  end

  def test_rack_url_scheme
    app = proc {}
    env = { "rack.url_scheme" => "https", "SERVER_NAME" => "example.com", "SERVER_PORT" => 443 }
    base_url = BreezyPDF::Intercept::Base.new(app, env).send(:base_url)

    assert_equal("https://example.com", base_url)
  end
end
