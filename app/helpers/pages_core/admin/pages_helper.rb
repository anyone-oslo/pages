# encoding: utf-8

module PagesCore::Admin::PagesHelper

	def page_name_cache
		@page_name_cache ||= {}
		@page_name_cache
	end

	def available_templates_for_select
		PagesCore::Templates.names.collect do |template|
			if template == "index"
				[ "[Default]", "index" ]
			else
				[ template.humanize, template ]
			end
		end
	end

	def page_name(page, options={})
		page_name_cache[options] ||= {}

		if page_name_cache[options][page.id]
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
