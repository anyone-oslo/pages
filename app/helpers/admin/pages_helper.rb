# encoding: utf-8

module Admin
  module PagesHelper
    def available_templates_for_select
      PagesCore::Templates.names.collect do |template|
        if template == "index"
          ["[Default]", "index"]
        else
          [template.humanize, template]
        end
      end
    end

    def page_name(page, options = {})
      page_names = if options[:include_parents]
                     [page.ancestors, page].flatten
                   else
                     [page]
                   end
      safe_join(
        page_names.map { |p| page_name_with_fallback(p) },
        " &raquo; ".html_safe
      )
    end

    def publish_time(time)
      if time.year != Time.now.year
        time.strftime("on %b %d %Y at %H:%M")
      elsif time.to_date != Time.now.to_date
        time.strftime("on %b %Y at %H:%M")
      else
        time.strftime("at %H:%M")
      end
    end

    private

    def page_name_with_fallback(page)
      if page.name?
        page.name.to_s
      elsif page.localize(I18n.default_locale.to_s).name?
        "(#{page.localize(I18n.default_locale.to_s).name})"
      else
        "(Untitled)"
      end
    end
  end
end
