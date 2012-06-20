# encoding: utf-8

require 'pages_core'
PagesCore.init!

# reCAPTCHA config
Recaptcha.configure do |config|
	config.public_key  = '***REMOVED***'
	config.private_key = '***REMOVED***'
end

# Initialize and configure Haml/Sass
require 'sass'
require 'sass/plugin' if defined?(Sass)

Sass::Plugin.options[:template_location] = Rails.root.join('app', 'assets', 'stylesheets').to_s

# Make the plugin reloadable
#ActiveSupport::Dependencies.load_once_paths.delete(PagesCore.plugin_root.join('lib').to_s)
#ActiveSupport::Dependencies.load_once_paths.delete(PagesCore.plugin_root.join('app', 'models').to_s)
ActiveSupport::Dependencies.load_once_paths.delete(PagesCore.plugin_root.join('app', 'helpers').to_s)
ActiveSupport::Dependencies.load_once_paths.delete(PagesCore.plugin_root.join('app', 'controllers').to_s)
