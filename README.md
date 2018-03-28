# BreezyPDF

[![Build Status](https://travis-ci.org/danielwestendorf/breezy_pdf-ruby.svg?branch=master)](https://travis-ci.org/danielwestendorf/breezy_pdf-ruby) [![Gem Version](https://badge.fury.io/rb/breezy_pdf.svg)](https://badge.fury.io/rb/breezy_pdf)

Make PDF generation a breezy-easy.

No binaries to install. No reinventing the wheel to match HTML layouts. Just simple HTML to PDF generation as a Rack Middleware with support for modern CSS and JavaScript. `.pdf` any of your app's URL's for fast, out-of-process, PDF generation of that URL. Support for public and authenticated views, local development and production.

[Sign Up](https://BreezyPDF.com/) for an account to get started.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'breezy_pdf'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install breezy_pdf

## Usage - Ruby on Rails

To add the middleware:

```ruby
# config/application.rb

BreezyPDF.secret_api_key = "YOUR_SECRET_API_KEY" # Remove if specified elsewhere
config.middleware.use BreezyPDF::Middleware
```

```ruby
# view.html.erb
<%= link_to "Download as PDF", my_resource_path(format: :pdf) %>
```

Proceed to configuration.

## Usage - Sinatra/Hamani/Rack

To add the middleware:

```ruby
# app.rb

BreezyPDF.secret_api_key = "YOUR_SECRET_API_KEY" # Remove if specified elsewhere
use BreezyPDF::Middleware
```

```ruby
# view.html
<a href="/this/url.pdf">Download as PDF</a>
```

Proceed to configuration.

## Configuration

BreezyPDF supports extensive configuration for how want PDF's to render:

```ruby
# config/initializers/breezy_pdf.rb

BreezyPDF.setup do |config|
  # Secret API Key
  #
  # Obtain an API key from https://breezypdf.com
  # Store your API key in a secure location with the rest of your app secrets
  config.secret_api_key = "YOUR_SECRET_API_KEY"


  # Middleware Path Matchers
  #
  # An array for Regular Expressions which identify which URL's should be
  # intercepted by the Middleware. Defaults to [/\.pdf/], which will match
  # all requests containing a .pdf extension.
  # config.middleware_path_matchers = [/\.pdf/]


  # Treat URL's as Private
  #
  # This indicates if the URL requested is protected or unaccessible for the
  # public Internet. Examples of this would be when hosted on localhost (development)
  # URL's which are protected by authentication, or URL's that depend on session/cookie
  # data to display correctly. Default is true.
  #
  # config.treat_urls_as_private = true


  # Upload Assets
  #
  # Express your desire to upload assets within the requested HTML which are not
  # publicly accessible with a FQDN. This might include images, CSS, and
  # JavaScript when running in development mode, or assets which are referenced
  # with relative URL's. If you're able to turn this off, performance will be increased
  # Default is true.
  #
  # Only applicable when `config.treat_urls_as_private == true`
  #
  # config.upload_assets = true
  #
  # or, if your assets are only publicly available on production
  # config.upload_assets = Rails.env.development?


  # Asset Selectors
  #
  # Configure what types of assets should be evaluated to be uploaded. Expects an
  # array of string CSS selectors. Default is `[img script link[rel="stylesheet"]]`.
  #
  # Only applicable when `config.treat_urls_as_private == true`
  # Only applicable when `config.upload_assets == true`
  #
  # config.asset_selectors = %w(img script link[rel="stylesheet"])


  # Asset path matchers
  #
  # Determine which attribute path's to replace with an uploaded version of the asset.
  # Expects a hash of attr: Regexp values. Default is `{ href: /^\/\w+/, src: /^\/\w+/}`
  # which matches all relative paths.
  #
  # Only applicable when `config.treat_urls_as_private == true`
  # Only applicable when `config.upload_assets == true`
  #
  # config.asset_path_matchers = {
  #   href: %r{^\/\w+},
  #   src:  %r{^\/\w+}
  # }


  # Extract Metadata
  #
  # BreezyPDF supports specifying how a page should be rendered through meta tags within
  # the HTML to be rendered. Contact support@breezypdf.com for more details. Default is
  # true.
  #
  # Only applicable when `treat_urls_as_private == true`
  # config.extract_metadata = true


  # Threads
  #
  # Specify the maximum number of Threads to use when uploading assets. This speeds up the
  # uploading of assets by doing them concurrently. Default is 1.
  #
  # Only applicable when `config.treat_urls_as_private == true`
  # Only applicable when `config.upload_assets == true`
  #
  # config.threads = 1


  # Filter Elements
  #
  # Remove certain elements from the HTML which shouldn't be included in the PDF, such as
  # a navigation or footer elements. Default is false.
  #
  # Only applicable when `config.treat_urls_as_private == true`
  #
  # config.fitler_elements = false


  # Filter Elements Selectors
  #
  # CSS selectors to configure which element you'd like to remove. Expects an array of of
  # CSS selectors. Default is `[.breezy-pdf-remove]`.
  #
  # Only applicable when `config.treat_urls_as_private == true`
  #
  # config.filtered_element_selectors = %w[.breezy-pdf-remove]

  # Logger
  #
  # Configure the logger, if you're into that sort of thing.
  #
  # config.logger = Logger.new(STDOUT).tap { |logger| logger.level = Logger::FATAL }
end
```

## Where's my loading animation?

By default, the requested PDF will eventually returned by the request after a series of redirects. The PDF will be sent with a Content-Disposition of `attachment`, so the browser will attempt to download it instead of showing it inline. All the while, and after the PDF has been downloaded, the current page's HTML will continue to be displayed.

If you want to show a loading animation on the current page, you can simply load the PDF with an AJAX request, eventually redirecting to the final URL.

Here is a contrived example:

```html
<a href="/this/path.pdf" class="breezy-pdf-download">Download as PDF</a>

<script type="text/javascript">
  var downloadLinkEls = document.querySelectorAll('.breezy-pdf-download');
  var loadingEl = document.createElement('div');
  loadingEl.innerHTML = "<h1>Loading!</h1><p>Loading icon here, maybe?</p><p id='breezy-progress'></p>";
  loadingEl.style = "position: absolute; width: 100%; height: 100%; text-align: center; background: #fff; top: 0; left: 0; z-index: 10000; display: none;"

  document.body.appendChild(loadingEl);
  var progressEl = document.getElementById('breezy-progress');

  for (var i = downloadLinkEls.length - 1; i >= 0; i--) {
    var linkEl = downloadLinkEls[i];
    var pdfUrl = linkEl.getAttribute('href');

    // Listen for a click on the link, then start handling the change of state
    linkEl.addEventListener('click', function(ev) {
      loadingEl.style.display = "block"; // Display ad-hoc loading element
      ev.preventDefault();

      var i = 1;
      var interval = setInterval(function() {
        progressEl.innerText = i / 10.0 + ' waiting seconds so far...';
        i++;
      }, 100);

      var ajaxRequest = new XMLHttpRequest();

      ajaxRequest.addEventListener('load', function(ev) {
        clearInterval(interval);
        console.log("Done waiting. We'd close modals or remove loading animations here before setting the location.")
        loadingEl.style.display = "none";

        // Redirect the eventual URL of the PDF
        // If the browser downloads the file, the current page's HTML will still be shown
        window.location = ev.currentTarget.responseURL;
      })

      ajaxRequest.open('GET', pdfUrl);
      ajaxRequest.send();
    })
  }
</script>
```

## Pragmatic access

You may want to render a PDF out of the HTTP request cycle like in a background job or mailer. BreezyPDF supports rendering HTML as a PDF pragmatically. BreezyPDF::HTML2PDF expects two arguments, the `asset_host` for assets, and the html fragment. The `asset_host` should be the locally accessible host where external assets (js, css) can be downloaded from. In development, this may be `http://localhost:3000`, while in production it may be your configured `Rails.application.config.action_controller.asset_host`. If `BreezyPDF.upload_assets == false`, then this value has no impact.

Here is an example of how you might do that:

```
def invoice_mailer(user, invoice)
  asset_host = Rails.env.production? ? Rails.application.config.action_controller.asset_host : "http://localhost:3000"

  html = ActionController::Renderer.render(template "invoices/show", assigns: { invoice: invoice }, locals: { current_user: user })
  pdf = BreezyPDF::HTML2PDF.new(, html)

  attachments["invoice-#{invoice.id}.pdf"] = pdf.to_file.read
  @pdf_url = pdf.to_url
end
```

This example uses [ActionController::Renderer](http://api.rubyonrails.org/classes/ActionController/Renderer.html) to render a controller template's html.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/danielwestendorf/breezy_pdf.

## License

Copyright (c) Daniel Westendorf

BreezyPDF is an Open Source project licensed under the terms of
the LGPLv3 license.  Please see <http://www.gnu.org/licenses/lgpl-3.0.html>
for license text.
