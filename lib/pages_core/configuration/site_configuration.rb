module PagesCore
	module Configuration
		class SiteConfiguration < PagesCore::Configuration::Handler
			
			default_handler do |conf, setting, args|
				conf.set(setting, args)
			end
			
			handle :newsletter do |conf, setting, args|
				conf.set([:newsletter, setting], args)
			end
			
			# Depreceated, use newsletter.template
			def newsletter_template(value)
				newsletter.template(value)
			end

			# Depreceated, use newsletter.image
			def newsletter_image(value)
				newsletter.image(value)
			end
		end
	end
end