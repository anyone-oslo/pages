# frozen_string_literal: true

module PagesCore
  class FormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::TagHelper
    include PagesCore::LabelledFormBuilder

    def image_file_preview(attribute)
      return "" unless object.send(attribute) &&
                       !object.send(attribute).new_record?

      tag.p(
        @template.dynamic_image_tag(object.send(attribute), size: "120x100")
      )
    end

    def image_file_field(attribute, options = {})
      safe_join [image_file_preview(attribute), file_field(attribute, options)]
    end
  end
end
