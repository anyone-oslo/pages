require File.join(File.dirname(__FILE__), 'templates/block_configuration')
require File.join(File.dirname(__FILE__), 'templates/configuration')
require File.join(File.dirname(__FILE__), 'templates/template_configuration')

module PagesCore
	module Templates
		class << self
			def names
				unless (@@available_templates_cached ||= nil)
					templates = [
						File.join(PagesCore.plugin_root, 'app/views/pages/templates'),
						File.join(RAILS_ROOT,            'app/views/pages/templates')
					].map do |location|
						Dir.entries(location).select{|f| File.file?(File.join(location, f)) and !f.match(/^_/)} if File.exists?(location)
					end
					templates = templates.flatten.uniq.compact.sort.map{|f| f.gsub(/\.[\w\d\.]+$/,'')}

					# Move the index template to the front
					if templates.include?("index")
						templates = ["index", templates.reject{|f| f == "index"}].flatten
					end
					@@available_templates_cached = templates
				end
				return @@available_templates_cached
			end
		end	
	end
end