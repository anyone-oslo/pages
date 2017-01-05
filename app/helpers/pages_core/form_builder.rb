# encoding: utf-8

module PagesCore
  class FormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::TagHelper

    def field_with_label(attr, str, label = nil)
      classes = ["field"]
      classes << "field-with-errors" if object.errors[attr].any?
      content_tag(:div, label_for(attr, label) + str, class: classes.join(" "))
    end

    def image_file_preview(attribute)
      return "" unless object.send(attribute) &&
                       !object.send(attribute).new_record?
      content_tag(
        :p, @template.dynamic_image_tag(object.send(attribute), size: "120x100")
      )
    end

    def image_file_field(attribute, options = {})
      safe_join [image_file_preview(attribute), file_field(attribute, options)]
    end

    def label_and_errors(attribute, label_text)
      return label_text unless object.errors[attribute].any?
      safe_join(
        [label_text,
         content_tag(:span, object.errors[attribute].first, class: "error")],
        " ")
    end

    def label_for(attribute, label_text = nil)
      label_text ||= object.class.human_attribute_name(attribute)
      content_tag("label", label_and_errors(attribute, label_text),
                  for: [object.class.to_s.underscore, attribute].join("_"))
    end

    def labelled_check_box(
      attribute, label_text = nil, options = {},
      checked_value = "1", unchecked_value = "0"
    )
      labelled_field(attribute, label_text, options) do |opts|
        check_box(attribute, opts, checked_value, unchecked_value)
      end
    end

    def labelled_country_select(
      attr, label = nil, priority = {}, opts = {}, html_opts = {}
    )
      if priority.is_a?(Hash)
        return labelled_field(attr, label, priority) do |options|
          country_select(attr, options, opts, html_opts)
        end
      end
      labelled_field(attr, label, opts) do |options|
        country_select(attr, priority, options, html_opts)
      end
    end

    def labelled_date_select(attribute, label_text = nil, options = {})
      labelled_field(attribute, label_text, options) do |opts|
        date_select(attribute, opts)
      end
    end

    def labelled_datetime_select(attribute, label_text = nil, options = {})
      labelled_field(attribute, label_text, options) do |opts|
        datetime_select(attribute, opts)
      end
    end

    def labelled_file_field(attribute, label_text = nil, options = {})
      labelled_field(attribute, label_text, options) do |opts|
        file_field(attribute, opts)
      end
    end

    def labelled_image_file_field(attribute, label_text = nil, options = {})
      labelled_field(attribute, label_text, options) do |opts|
        image_file_field(attribute, opts)
      end
    end

    def labelled_password_field(attribute, label_text = nil, options = {})
      labelled_field(attribute, label_text, options) do |opts|
        password_field(attribute, opts)
      end
    end

    def labelled_select(attribute, choices, label_text = nil, options = {})
      labelled_field(attribute, label_text, options) do |opts|
        select(attribute, choices, opts)
      end
    end

    def labelled_text_area(attribute, label_text = nil, options = {})
      labelled_field(attribute, label_text, options) do |opts|
        text_area(attribute, opts)
      end
    end

    def labelled_text_field(attribute, label_text = nil, options = {})
      labelled_field(attribute, label_text, options) do |opts|
        text_field(attribute, opts)
      end
    end

    def labelled_time_select(attribute, label_text = nil, options = {})
      labelled_field(attribute, label_text, options) do |opts|
        time_select(attribute, opts)
      end
    end

    protected

    def labelled_field(attribute, label_text = nil, options = {})
      if label_text.is_a?(Hash) && options == {}
        options = label_text
        label_text = nil
      end
      field_with_label(attribute, yield(options), label_text)
    end
  end
end
