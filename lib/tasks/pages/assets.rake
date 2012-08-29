# encoding: utf-8

require 'find'
require 'open-uri'
require 'fileutils'
require 'pathname'

namespace :pages do
	namespace :assets do

		desc "Update jQuery"
		task :update_jquery => :environment do
			output = open('http://code.jquery.com/jquery.min.js').read
			File.open('app/assets/javascripts/jquery.js', 'w'){|fh| fh.write output}
		end

		desc "Update to SCSS"
		task :convert_to_scss => :environment do
			assets_dir = Rails.root.join('app', 'assets', 'stylesheets')
			Find.find(assets_dir) do |path|
				if path =~ /\.css$/
					scss_path = path.gsub(/\.css$/, '.css.scss')
					`git mv #{path} #{scss_path}`
				end
			end
		end

	end
end