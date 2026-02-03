# frozen_string_literal: true

module PagesCore
  module Admin
    module TagEditorHelper
      def tag_editor_for(form, object, attribute: :serialized_tags)
        object ||= form.object
        react_component(
          "TagEditor",
          { enabled: object.tags.map(&:name),
            tags: Tag.tags_and_suggestions_for(object, limit: 20)
                  .map(&:name),
            name: "#{form.object_name}[#{attribute}]" }
        )
      end
    end
  end
end
