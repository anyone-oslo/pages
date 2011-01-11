require File.join(File.dirname(__FILE__), 'dependencies/gem_loader')

module PagesCore
	module Dependencies

		def self.load_gems
			# GemLoader.run do |config|
			# 	#config.gem 'BlueCloth'
			# 	config.gem 'vector2d'
			# 	config.gem 'hpricot'
			# 	config.gem 'simple-rss'
			# 	config.gem 'RedCloth'
			# 	config.gem 'rmagick', :lib => 'RMagick'
			# 	config.gem 'uuidtools'
			# 	config.gem 'unicode'
			# 	config.gem 'daemon-spawn'
			# 	if ENV['RAILS_ENV'] == 'test'
			# 		config.gem 'thoughtbot-shoulda', :lib => 'shoulda'
			# 		config.gem 'notahat-machinist', :lib => 'machinist'
			# 		config.gem 'faker'
			# 	end
			# end
		end
		
		def self.load
			# Generic ruby libraries
			require 'digest/sha1'
			require 'iconv'
			require 'find'
			require 'open-uri'

			# Included in vendor/plugins/pages/lib
			[:acts_as_taggable, :session_cleaner, :language, :mumbojumbo, :enumerable, :feed_builder, :country_select, :catch_cookie_exception].each do |lib|
				require File.join(File.dirname(__FILE__), "../#{lib.to_s}")
			end
		end

	end
end