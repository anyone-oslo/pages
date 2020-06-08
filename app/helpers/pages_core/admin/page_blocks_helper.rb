# frozen_string_literal: true

module PagesCore
  module Admin
    module PageBlocksHelper
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

      private

      def localize_page_select_options(form, block_options)
        if block_options[:options].is_a?(Hash)
          block_options[:options][form.object.locale.to_sym]
        else
          block_options[:options]
        end
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
    end
  end
end
