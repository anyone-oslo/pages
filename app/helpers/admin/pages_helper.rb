module Admin
  module PagesHelper
    def available_templates_for_select
      PagesCore::Template.selectable.map(&:new).map { |t| [t.name, t.id] }
    end

    def file_embed_code(file)
      "[file:#{file.id}]"
    end

    def page_authors(page)
      ([page.author] + User.activated).uniq
    end

    def page_block_field(form, attr, options)
      template = form.object.template_config
      labelled_field(
        form.send(options[:size] == :field ? :text_field : :text_area,
                  attr,
                  page_block_field_options(form.object, attr, options)),
        template.block_name(attr),
        errors: form.object.errors[attr],
        description: template.block_description(attr)
      )
    end

    def page_name(page, options = {})
      page_names = if options[:include_parents]
                     [page.ancestors, page].flatten
                   else
                     [page]
                   end
      safe_join(
        page_names.map { |p| page_name_with_fallback(p) },
        raw(" &raquo; ")
      )
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

    def page_block_classes(class_name, block_options = {})
      [class_name, block_options[:class]].join(" ").strip
    end

    def page_block_field_options(object, attr, options = {})
      opts = { placeholder: object.template_config.block_placeholder(attr) }
      if options[:size] == :field
        opts.merge(class: page_block_classes("rich", options))
      else
        opts.merge(
          class: page_block_classes("rich", options),
          rows: (options[:size] == :large ? 15 : 5)
        )
      end
    end

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
