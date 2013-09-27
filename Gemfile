# encoding: utf-8

source 'http://rubygems.org'
source 'http://gems.manualdesign.no/'

gem 'rake', '0.9.2.2'
gem 'rails', '2.3.18'
gem 'mysql', '2.8.1'
gem 'rdoc', '3.12'

# This is explicitely held back for pages_console,
# the 0.2.x series are the last compatible with Rails 2.3.
gem 'mysql2', '~> 0.2.18'

gem "bcrypt-ruby", :require => "bcrypt"
gem 'capistrano'
gem 'capistrano_colors'
gem 'vector2d'
gem 'enumerable_mapper'
gem 'hpricot', '0.8.6'
gem 'simple-rss', '1.2.3'
gem 'RedCloth', '4.2.9'
gem 'rmagick', '2.12.2', :require => 'RMagick'
gem 'unicode', '0.3.1'
gem 'daemon-spawn', '0.2.0'
gem 'pages_console', '~> 0.4.16'
gem 'ruby-openid', :require => 'openid'
gem 'httparty', '0.6.1'
gem 'delayed_job', '2.0.8'

# DynamicImage
gem 'rmagick', '2.12.2', :require => 'RMagick'
gem 'dynamic_image-pages', :require => 'dynamic_image'
#gem 'dynamic_image-pages', :require => 'dynamic_image', :path => '~/Dev/gems/dynamic_image-pages'

# Assets
gem 'sprockets', '2.4.5'
gem 'sprockets-plugin'
gem 'sprockets-helpers', '0.7.2' # Hold this back until the fix for media: on stylesheet_link_tag is released
gem 'sass', '3.2.1'
gem 'json', '1.5.1'
gem 'coffee-script', '2.2.0'
gem 'coffee-script-source', '1.2.0'
#gem 'yui-compressor', :require => 'yui/compressor'

# ActiveRecord extensions
gem 'acts_as_list', '0.1.4'
gem 'acts_as_tree', '0.1.1'

# reCAPTCHA
gem "recaptcha", '0.3.4', :require => "recaptcha/rails"

# Thinking Sphinx
gem 'riddle'
gem 'thinking-sphinx', '1.5.0'
gem 'ts-delayed-delta', '1.1.3', :require => 'thinking_sphinx/deltas/delayed_delta'

gem 'term-ansicolor'

#gem 'ruby-openid', :git => 'git://github.com/xxx/ruby-openid.git', :require => 'openid'

# Load gems from plugins
plugins_dir = File.join(File.dirname(__FILE__), '..')
Dir.entries(plugins_dir).each do |plugin|
  plugin_gemfile = File.join(plugins_dir, plugin, 'Gemfile')
  if File.exist?(plugin_gemfile) && plugin != "pages"
    self.instance_eval(Bundler.read_file(plugin_gemfile.to_s), plugin_gemfile.to_s, 1)
  end
end
