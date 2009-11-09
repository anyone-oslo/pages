require File.join(File.dirname(__FILE__), 'dependencies/gem_loader')

module PagesCore
	module Dependencies

		def self.load_gems
			GemLoader.run do |config|
				#config.gem 'BlueCloth'
				config.gem 'vector2d'
				config.gem 'hpricot'
				config.gem 'simple-rss'
				config.gem 'RedCloth'
				config.gem 'rmagick'
				config.gem 'uuidtools'
				config.gem 'unicode'
				if ENV['RAILS_ENV'] == 'test'
					config.gem 'thoughtbot-shoulda', :lib => 'shoulda'
					config.gem 'notahat-machinist', :lib => 'machinist'
					config.gem 'faker'
				end
			end
		end
		
		def self.load
			# Generic ruby libraries
			require 'digest/sha1'
			require 'iconv'
			require 'find'
			require 'open-uri'

			# Included in vendor/plugins/pages/lib
			[:acts_as_taggable, :session_cleaner, :apparat, :language, :mumbojumbo, :enumerable, :feed_builder].each do |lib|
				require File.join(File.dirname(__FILE__), "../#{lib.to_s}")
			end
			# require 'acts_as_taggable'
			# require 'session_cleaner'
			# require 'apparat'
			# require 'language'
			# require 'mumbojumbo'
			# require 'enumerable'
			# require 'feed_builder'
		end

	end
end