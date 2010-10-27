source 'http://rubygems.org'
source 'http://gems.manualdesign.no/gems/'
#source 'http://gems.github.com'

gem 'rails', '2.2.2'
gem 'mysql'

gem 'capistrano'
gem 'vector2d'
gem 'enumerable_mapper'
gem 'hpricot'
gem 'simple-rss'
gem 'RedCloth', '4.0.4'
gem 'rmagick', '2.12.2', :require => 'RMagick'
gem 'uuidtools'
gem 'unicode'
gem 'daemon-spawn', '0.2.0'
gem 'aws-s3', '0.6.2'
gem 'pages_console'
gem 'ruby-openid', :require => 'openid'
gem 'httparty'
gem 'json'
#gem 'ruby-openid', :git => 'git://github.com/xxx/ruby-openid.git', :require => 'openid'

group :test do
	gem 'shoulda'
	gem 'machinist'
	gem 'faker'
end

# Load gems from plugins
plugins_dir = File.join(File.dirname(__FILE__), '..')
Dir.entries(plugins_dir).each do |plugin|
	plugin_gemfile = File.join(plugins_dir, plugin, 'Gemfile')
	if File.exist?(plugin_gemfile) && plugin != "pages"
		self.instance_eval(Bundler.read_file(plugin_gemfile.to_s), plugin_gemfile.to_s, 1)
	end
end