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