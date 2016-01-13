# encoding: utf-8

module Admin
  module PagesHelper
    def page_block_field(form, block_name, block_options)
      if block_options[:size] == :field
        labelled_field(
          form.text_field(
            block_name,
            class:       ['text', block_options[:class]].join(" "),
            placeholder: block_options[:placeholder]
          ),
          block_options[:title],
          errors:      form.object.errors[block_name],
          description: block_options[:description]
        )
      else
        labelled_field form.text_area(
          block_name,
          rows:        (block_options[:size] == :large ? 15 : 5),
          class:       ['rich', block_options[:class]].join(" "),
          placeholder: block_options[:placeholder]
        ),
          block_options[:title],
          errors:      form.object.errors[block_name],
          description: block_options[:description]
      end
    end

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

    def file_embed_code(file)
      "[file:#{file.id}]"
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
