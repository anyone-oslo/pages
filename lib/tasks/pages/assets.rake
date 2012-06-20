# encoding: utf-8

require 'find'
require 'open-uri'

namespace :pages do
	namespace :assets do

		desc "Compile assets"
		task :compile => :environment do
			PagesCore::Assets.compile!(:force => true)
		end

		desc "Update jQuery"
		task :update_jquery => :environment do
			output = open('http://code.jquery.com/jquery.min.js').read
			File.open('app/assets/javascripts/jquery.js', 'w'){|fh| fh.write output}
			PagesCore::Assets.compile!(:force => true)
		end

		desc "Update to SCSS"
		task :convert_to_scss => :environment do
			assets_dir = Rails.root.join('app', 'assets', 'stylesheets')
			Find.find(assets_dir) do |path|
				if path =~ /\.css$/
					scss_path = path.gsub(/\.css$/, '.scss')
					`git mv #{path} #{scss_path}`
				end
			end
		end

	end
end