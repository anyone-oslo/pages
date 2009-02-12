# Gem dependencies
gem 'vector2d'
#require 'manual_support'

require 'digest/sha1'
require 'enumerable_mapper'
require 'acts_as_ferret'
require 'acts_as_taggable'
require 'session_cleaner'
require 'apparat'
require 'language'
require 'mumbojumbo'
require 'pages_core'
require 'iconv'
require 'enumerable'
require 'feed_builder'

# Patch String to include iconv method
class String
	def iconv( to, from )
		Iconv.iconv( to, from, self )
	end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::Taggable)

#if defined?(Mongrel)
#  require "mongrel_proctitle"
#end

MumboJumbo.load_languages!
MumboJumbo.translators << PagesCore::StringTranslator

Mime::Type.register "application/rss+xml", 'rss'


# This should probably not be here
class Image < ActiveRecord::Base
	has_many :album_images
	has_many :albums, :through => :album_images
end