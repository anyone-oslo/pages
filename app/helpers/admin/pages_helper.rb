# encoding: utf-8

module Admin::PagesHelper
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
        elsif p.localize(I18n.default_locale.to_s).name?
          "(#{p.localize(I18n.default_locale.to_s).name.to_s})"
        else
          "(Untitled)"
        end
      end.join(" &raquo; ")

      page_name_cache[options][page.id] = p_name
    end
  end

  def publish_time(time)
    date_string = (time.to_date == Time.now.to_date) ? "at " : "on "

    if time.to_date == Time.now.to_date
      date_string += time.strftime("%H:%M")
    elsif time.year == Time.now.year
      date_string += time.strftime("%b %d")
      date_string += time.strftime(" at %H:%M")
    else
      date_string += time.strftime("%b %d %Y")
      date_string += time.strftime(" at %H:%M")
    end

    date_string
  end

end
