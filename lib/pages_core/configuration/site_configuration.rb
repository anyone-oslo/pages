module PagesCore
	module Configuration
		class SiteConfiguration < PagesCore::Configuration::Handler
			
			default_handler do |conf, setting, *args|
				if setting.to_s =~ /\?$/
					value = conf.get(setting.to_s.gsub(/\?$/, '').to_sym)
					(value && value != :disabled) ? true : false
				else
					(args && args.length > 0) ? conf.set(setting, *args) : conf.get(setting)
				end
			end
			
			handle :newsletter do |conf, setting, *args|
				if setting.to_s =~ /\?$/
					value = conf.get(:newsletter, setting.to_s.gsub(/\?$/, '').to_sym)
					(value && value != :disabled) ? true : false
				else
					(args && args.length > 0) ? conf.set([:newsletter, setting], *args) : conf.get(:newsletter, setting)
				end
			end
			
			def templates
				PagesCore::Templates.configuration
			end
			
			# Depreceated, use newsletter.template
			def newsletter_template(value)
				::ActiveSupport::Deprecation.warn( 
					":newsletter_template configuration option is depreceated, use newsletter.template", 
					caller)
				newsletter.template(value)
			end

			# Depreceated, use newsletter.image
			def newsletter_image(value)
				::ActiveSupport::Deprecation.warn( 
					":newsletter_image configuration option is depreceated, use newsletter.image", 
					caller)
				newsletter.image(value)
			end
			
			# Depreceated, use the template config
			def page_additional_images(value)
				::ActiveSupport::Deprecation.warn( 
					":page_additional_images configuration option is depreceated, use the template config", 
					caller)
				templates.default.images value
			end

			# Depreceated, use the template config
			def page_image_is_linkable(value)
				::ActiveSupport::Deprecation.warn( 
					":page_image_is_linkable configuration option is depreceated, use the template config", 
					caller)
				options = {:linkable => value}
				enabled = templates.get(:default, :image, :value)
				templates.default.image enabled, options
			end

			# Depreceated, use the template config
			def page_files(value)
				::ActiveSupport::Deprecation.warn( 
					":page_files configuration option is depreceated, use the template config", 
					caller)
				templates.default.files value
			end

			# Depreceated, use the template config
			def text_filter(value)
				::ActiveSupport::Deprecation.warn( 
					":text_filter configuration option is depreceated, use the template config", 
					caller)
				templates.default.text_filter value
			end
		end
	end
end