module Admin::PagesHelper
	
	def page_name_cache
		@page_name_cache ||= {}
		@page_name_cache
	end

	def available_templates_for_select
		Page.available_templates.collect do |template|
			if template == "index"
				[ "[Default]", "" ] 
			else
				[ template.humanize, template ]
			end
		end
	end
	
	def page_name(page, options={})
		page_name_cache[options] ||= {}

		if page_name_cache[options][page.id]
			logger.info " ** PAGE NAME CACHE HIT"
			page_name_cache[options][page.id]
		else
			page_names = (options[:include_parents]) ? [page.ancestors, page].flatten : [page]

			p_name = page_names.map do |p|
				if p.dup.name?
					p.dup.name.to_s
				elsif p.translate(Language.default).name?
					"(#{p.translate(Language.default).name.to_s})"
				else
					"(Untitled)"
				end
			end.join(" &raquo; ")

			page_name_cache[options][page.id] = p_name
		end
	end

end
