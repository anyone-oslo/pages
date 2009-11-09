require File.join(File.dirname(__FILE__), 'templates/configuration')

module PagesCore
	module Templates

		class BlockConfiguration
			attr_reader :name, :title, :description, :optional, :enforced
			def small?
				(@size == :small) ? true : false
			end
			def large?
				(small?) ? false : true
			end
		end
		
		class TemplateConfiguration
		end
		
		class << self
			def configure(options={}, &block)
				if options[:reset] == :defaults
					load_default_configuration
				elsif options[:reset] === true
					@@configuration = PagesCore::Templates::Configuration.new
				end
				yield self.configuration if block_given?
			end
			
			def load_default_configuration
				@@configuration = PagesCore::Templates::Configuration.new

				# Default template options
				config.default do |default|
					default.template       :autodetect, :root => 'index'
					default.image          :enabled, :linkable => (PagesCore.config(:page_image_is_linkable) ? true : false)
					default.files          PagesCore.config(:page_additional_files) ? :enabled : :disabled
					default.images         PagesCore.config(:additional_images) ? :enabled : :disabled
					default.text_filter    PagesCore.config(:text_filter) ? PagesCore.config(:text_filter) : :textile
					default.enabled_blocks [:headline, :excerpt, :body]
					default.blocks do |block|
						block.body     "Body",       :optional => false, :enforced => true, :size => :large
						block.headline "Headline",   :description => 'The main statement, usually largest and boldest, describing the main story.', :size => :field
						block.excerpt  "Standfirst", :description => 'An introductory paragraph before the start of the body.'
					 	block.boxout   "Boxout",     :description => 'Part of the page, usually background info or facts related to the article.'
					end
				end
			end
			
			def configuration
				load_default_configuration unless self.class_variables.include?('@@configuration')
				@@configuration
			end
			alias :config :configuration
		end
		
	end
end

# -- debug

module PagesCore
	def self.config(*args)
		false
	end
end

puts PagesCore::Templates.configuration.inspect