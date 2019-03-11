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

    def file_embed_code(file)
      "[file:#{file.id}]"
    end

    def news_section_name(page, news_pages)
      if news_pages.select { |p| p.name == page.name }.length > 1
        page_name(page, include_parents: true)
      else
        page_name(page)
      end
    end

    def page_authors(page)
      ([page.author] + User.activated).uniq
    end

    def page_block_field(form, block_name, block_options)
      labelled_field(
        if block_options[:type] == :select
          page_block_select(form, block_name, block_options)
        else
          page_block_text_field(form, block_name, block_options)
        end,
        block_options[:title],
        errors: form.object.errors[block_name],
        description: block_options[:description]
      )
    end

    def page_block_select(form, block_name, block_options)
      opts = localize_page_select_options(form, block_options)
      opts = opts.call if opts.is_a?(Proc)
      opts = opts.map { |v| [v, v] } unless nested_array?(opts)
      opts = ([["", nil]] + opts).uniq

      value = form.object.send(block_name)
      opts << [value, value] unless opts.map(&:last).include?(value)

      form.send(:select, block_name, opts)
    end

    def page_block_text_field(form, block_name, block_options)
      form.send(
        block_options[:size] == :field ? :text_field : :rich_text_area,
        block_name,
        page_block_field_options(block_options)
      )
    end

    def page_name(page, options = {})
      page_names = if options[:include_parents]
                     page.self_and_ancestors.reverse
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

    def localize_page_select_options(form, block_options)
      if block_options[:options].is_a?(Hash)
        block_options[:options][form.object.locale.to_sym]
      else
        block_options[:options]
      end
    end

    def nested_array?(array)
      array.present? && array.first.is_a?(Array)
    end

    def page_block_classes(class_name, block_options = {})
      [class_name, block_options[:class]].join(" ").strip
    end

    def page_block_field_options(block_options = {})
      opts = { placeholder: block_options[:placeholder] }
      if block_options[:size] == :field
        opts.merge(class: page_block_classes("rich", block_options))
      else
        opts.merge(
          class: page_block_classes("rich", block_options),
          rows: (block_options[:size] == :large ? 15 : 5)
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
