# frozen_string_literal: true

module Admin
  module PagesHelper
    def autopublish_notice(page)
      return unless page.autopublish?

      tag.div(class: "autopublish-notice") do
        safe_join(["This page will be published",
                   tag.b(publish_time(page.published_at))], " ")
      end
    end

    def news_section_name(page, news_pages)
      if news_pages.count { |p| p.name == page.name } > 1
        page_name(page, include_parents: true)
      else
        page_name(page)
      end
    end

    def page_authors(page)
      ([page.author] + User.activated).uniq
    end

    def page_list_row(page, &)
      classes = [page.status_label.downcase]
      classes << "autopublish" if page.autopublish?
      classes << "pinned" if page.pinned?

      tag.tr(capture(&), class: classes.join(" "))
    end

    def page_name(page, options = {})
      page_names = if options[:include_parents]
                     page.self_and_ancestors.reverse
                   else
                     [page]
                   end
      safe_join(page_names.map { |p| page_name_with_fallback(p) }, " » ")
    end

    def page_published_status(page)
      return page_published_date(page) if page.published?
      return tag.em("Not published") if page.status_label == "Published"

      tag.em(page.status_label)
    end

    def page_published_date(page)
      if page.published_at.year == Time.zone.now.year
        l(page.published_at, format: :pages_date)
      else
        l(page.published_at, format: :pages_full)
      end
    end

    def publish_time(time)
      if time.year != Time.zone.now.year
        time.strftime("on %b %d %Y at %H:%M")
      elsif time.to_date != Time.zone.now.to_date
        time.strftime("on %b %d at %H:%M")
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
