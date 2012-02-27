source 'http://rubygems.org'
source 'http://gems.manualdesign.no/gems/'
#source 'http://gems.github.com'

gem 'rake', '0.8.7'
gem 'rails', '2.3.14'
gem 'mysql', '2.8.1'

gem 'capistrano'
gem 'vector2d'
gem 'enumerable_mapper'
gem 'hpricot', '0.8.2'
gem 'simple-rss', '1.2.3'
gem 'RedCloth', '4.0.4'
gem 'rmagick', '2.12.2', :require => 'RMagick'
gem 'uuidtools', '2.1.1'
gem 'unicode', '0.3.1'
gem 'daemon-spawn', '0.2.0'
gem 'aws-s3', '0.6.2'
gem 'pages_console'
gem 'ruby-openid', :require => 'openid'
gem 'httparty', '0.6.1'
gem 'sass', '3.1.1'
gem 'json', '1.5.1'
gem 'coffee-script', '2.1.3'
gem 'uuid', '2.3.5'
gem 'delayed_job', '2.0.7'

# Thinking Sphinx
gem 'riddle', '1.0.12'
gem 'thinking-sphinx', '1.3.20'
gem 'ts-delayed-delta', '1.1.1', :require => 'thinking_sphinx/deltas/delayed_delta'

#gem 'ruby-openid', :git => 'git://github.com/xxx/ruby-openid.git', :require => 'openid'

# Load gems from plugins
plugins_dir = File.join(File.dirname(__FILE__), '..')
Dir.entries(plugins_dir).each do |plugin|
	plugin_gemfile = File.join(plugins_dir, plugin, 'Gemfile')
	if File.exist?(plugin_gemfile) && plugin != "pages"
		self.instance_eval(Bundler.read_file(plugin_gemfile.to_s), plugin_gemfile.to_s, 1)
	end
end
