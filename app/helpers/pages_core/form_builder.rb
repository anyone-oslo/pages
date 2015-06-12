# encoding: utf-8

module PagesCore
  class FormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::TagHelper

    # Are there any errors on this attribute?
    def errors_on?(attribute)
      errors_on(attribute).length > 0
    end

    # Returns all errors for the attribute
    def errors_on(attribute)
      errors = object.errors[attribute] || []
      errors = [errors] unless errors.is_a?(Array)
      errors
    end

    # Returns the first error on attribute
    def first_error_on(attribute)
      errors_on(attribute).first
    end

    def image_file_field(attribute, options = {})
      if object.send(attribute)
        content_tag(
          "p",
          @template.dynamic_image_tag(object.send(attribute), size: "120x100")
        ) + file_field(attribute, options)
      else
        file_field(attribute, options)
      end
    end

    def field_with_label(attribute, content, label_text = nil)
      classes = ["field"]
      classes << "field_with_errors" if errors_on?(attribute)
      content_tag(
        "div",
        label_for(attribute, label_text) + content,
        class: classes.join(" ")
      )
    end

    def label_for(attribute, label_text = nil)
      label_text ||= object.class.human_attribute_name(attribute)
      if errors_on?(attribute)
        label_text += " <span class=\"error\">" +
          first_error_on(attribute) +
          "</span>"
      end
      content_tag(
        "label",
        label_text.html_safe,
        for: [object.class.to_s.underscore, attribute].join("_")
      )
    end

    def labelled_text_field(attribute, label_text = nil, options = {})
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(
        attribute,
        text_field(attribute, options),
        label_text
      )
    end

    def labelled_text_area(attribute, label_text = nil, options = {})
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(
        attribute,
        text_area(attribute, options),
        label_text
      )
    end

    def labelled_country_select(
      attribute,
      label_text = nil,
      priority_or_options = {},
      options = {},
      html_options = {}
    )
      if priority_or_options.is_a?(Hash)
        label_text, priority_or_options = parse_label_text_and_options(
          label_text,
          priority_or_options
        )
      else
        label_text, options = parse_label_text_and_options(
          label_text,
          options
        )
      end
      field_with_label(
        attribute,
        country_select(attribute, priority_or_options, options, html_options),
        label_text
      )
    end

    def labelled_date_select(attribute, label_text = nil, options = {})
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(
        attribute,
        date_select(attribute, options),
        label_text
      )
    end

    def labelled_datetime_select(attribute, label_text = nil, options = {})
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(
        attribute,
        datetime_select(attribute, options),
        label_text
      )
    end

    def labelled_time_select(attribute, label_text = nil, options = {})
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(
        attribute,
        time_select(attribute, options),
        label_text
      )
    end

    def labelled_select(attribute, choices, label_text = nil, options = {})
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(
        attribute,
        select(attribute, choices, options),
        label_text
      )
    end

    def labelled_check_box(
      attribute, label_text = nil, options = {},
      checked_value = "1", unchecked_value = "0"
    )
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(
        attribute,
        check_box(attribute, options, checked_value, unchecked_value),
        label_text
      )
    end

    def labelled_file_field(attribute, label_text = nil, options = {})
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(
        attribute,
        file_field(attribute, options),
        label_text
      )
    end

    def labelled_image_file_field(attribute, label_text = nil, options = {})
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(
        attribute,
        image_file_field(attribute, options),
        label_text
      )
    end

    def labelled_password_field(attribute, label_text = nil, options = {})
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(
        attribute,
        password_field(attribute, options),
        label_text
      )
    end

    protected

    def parse_label_text_and_options(label_text = nil, options = {})
      if label_text.is_a?(Hash) && options == {}
        options = label_text
        label_text = nil
      end
      [label_text, options]
    end
  end
end
