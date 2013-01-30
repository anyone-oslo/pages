module Sprockets
  def self.env
    @env ||= begin
      sprockets = Sprockets::Environment.new
      sprockets.append_path 'app/assets/images'
      sprockets.append_path 'app/assets/javascripts'
      sprockets.append_path 'app/assets/stylesheets'
      sprockets.append_plugin_paths
      #sprockets.css_compressor  = YUI::CssCompressor.new
      #sprockets.js_compressor   = YUI::JavaScriptCompressor.new

      sprockets
    end
  end

  def self.manifest
    @manifest ||= Sprockets::Manifest.new(env, Rails.root.join("public", "assets", "manifest.json"))
  end
end

Sprockets::Helpers.configure do |config|
  config.environment = Sprockets.env
  config.prefix      = '/assets'
  config.digest      = false
  config.manifest    = Sprockets.manifest
  config.public_path = Rails.root.join('public')
end


# This controls whether or not to use "debug" mode with sprockets.  In debug mode,
# asset tag helpers (like javascript_include_tag) will output the non-compiled
# version of assets, instead of the compiled version.  For example, if you had
# application.js as follows:
#
# = require jquery
# = require event_bindings
#
# javascript_include_tag "application" would output:
# <script src="/assets/jquery.js?body=1"></script>
# <script src="/assets/event_bindings.js?body=1"></script>
#
# If debug mode were turned off, you'd just get
# <script src="/assets/application.js"></script>
#
# Here we turn it on for all environments but Production
Rails.configuration.action_view.debug_sprockets = true unless Rails.env.production?
