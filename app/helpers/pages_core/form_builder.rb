# encoding: utf-8

module PagesCore
  class FormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::TagHelper

    # Returns all errors for the attribute
    def errors_on(attribute)
      errors = object.errors[attribute] || []
      errors = [errors] unless errors.is_a?(Array)
      errors
    end

    # Are there any errors on this attribute?
    def errors_on?(attribute)
      errors_on(attribute).any?
    end

    def field_with_label(attribute, content, label_text = nil)
      classes = ["field"]
      classes << "field-with-errors" if errors_on?(attribute)
      content_tag(
        "div",
        label_for(attribute, label_text) + content,
        class: classes.join(" ")
      )
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

    def labelled_check_box(
      attribute, label_text = nil, options = {},
      checked_value = "1", unchecked_value = "0"
    )
      labelled_field(attribute, label_text, options) do |opts|
        check_box(attribute, opts, checked_value, unchecked_value)
      end
    end

    def labelled_country_select(
      attribute,
      label_text = nil,
      priority_or_options = {},
      options = {},
      html_options = {}
    )
      if priority_or_options.is_a?(Hash)
        labelled_field(attribute, label_text, priority_or_options) do |opts|
          country_select(attribute, opts, options, html_options)
        end
      else
        labelled_field(attribute, label_text, options) do |opts|
          country_select(attribute, priority_or_options, opts, html_options)
        end
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
