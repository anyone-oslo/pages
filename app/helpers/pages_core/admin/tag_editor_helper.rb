module PagesCore
  module Admin
    module TagEditorHelper
      def tag_editor_for(
        form_helper, item, field_name = :serialized_tags, options = {}
      )
        tags = options[:tags] || Tag.tags_and_suggestions_for(item, limit: 20)
        tagged = options[:tagged] || item.tags
        options[:placeholder] ||= "Add tag..."
        content_tag(:div, class: "tag-editor clearfix") do
          form_helper.hidden_field(field_name, class: "serialized_tags") +
            tag_check_boxes(tags, tagged) +
            add_tag_button(options)
        end
      end

      private

      def tag_check_box(tag, tagged)
        content_tag(:span, class: :tag) do
          check_box_tag(
            "tag-#{tag.id}",
            1,
            tagged.include?(tag)
          ) + content_tag(:span, tag.name, class: :name)
        end
      end

      def tag_check_boxes(tags, tagged)
        content_tag(:div, class: :tags) do
          safe_join(tags.map { |t| tag_check_box(t, tagged) }, "")
        end
      end

      def add_tag_button(options = {})
        content_tag(:div, class: "add-tag-form") do
          text_field_tag(
            "add_tag",
            options[:placeholder],
            class: "add-tag"
          ) + content_tag(:button, "Add", class: "add-tag-button")
        end
      end
    end
  end
end
