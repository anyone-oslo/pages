# frozen_string_literal: true

module PagesCore
  module LabelledFormBuilder
    def field_with_label(attr, str, label = nil, class_name = nil)
      classes = ["field", class_name]
      classes << "field-with-errors" if object.errors[attr].any?
      tag.div(label_for(attr, label) + str, class: classes.compact.join(" "))
    end

    def label_and_errors(attribute, label_text)
      return label_text unless object.errors[attribute].any?

      error = tag.span(object.errors[attribute].first, class: "error")
      safe_join([label_text, error], " ")
    end

    def label_for(attribute, label_text = nil)
      label_text ||= object.class.human_attribute_name(attribute)
      tag.label(label_and_errors(attribute, label_text),
                for: [object.class.to_s.underscore, attribute].join("_"))
    end

    def labelled_check_box(
      attr, label = nil, options = {}, checked = "1", unchecked = "0"
    )
      labelled_field(attr, label, options) do |opts|
        check_box(attr, opts, checked, unchecked)
      end
    end

    def labelled_country_select(
      attr, label = nil, opts = {}, html_opts = {}
    )
      labelled_field(attr, label, opts) do |options|
        country_select(attr, options, html_opts)
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
      labelled_field(attribute, label_text, options, "text-field") do |opts|
        password_field(attribute, opts)
      end
    end

    def labelled_select(attribute, choices, label_text = nil, options = {})
      labelled_field(attribute, label_text, options) do |opts|
        select(attribute, choices, opts)
      end
    end

    def labelled_text_area(attribute, label_text = nil, options = {})
      labelled_field(attribute, label_text, options, "text-area") do |opts|
        text_area(attribute, opts)
      end
    end

    def labelled_text_field(attribute, label_text = nil, options = {})
      labelled_field(attribute, label_text, options, "text-field") do |opts|
        text_field(attribute, opts)
      end
    end

    def labelled_time_select(attribute, label_text = nil, options = {})
      labelled_field(attribute, label_text, options) do |opts|
        time_select(attribute, opts)
      end
    end

    protected

    def labelled_field(attr, label_text = nil, options = {}, class_name = nil)
      if label_text.is_a?(Hash) && options == {}
        options = label_text
        label_text = nil
      end
      field_with_label(attr, yield(options), label_text, class_name)
    end
  end
end
