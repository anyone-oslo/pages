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
      errors = [errors] unless errors.kind_of?(Array)
      errors
    end

    # Returns the first error on attribute
    def first_error_on(attribute)
      errors_on(attribute).first
    end

    def field_with_label(attribute, content, label_text=nil)
      classes = ['field']
      classes << 'field_with_errors' if errors_on?(attribute)

      label_text ||= object.class.human_attribute_name(attribute)
      if errors_on?(attribute)
        label_text += " <span class=\"error\">#{first_error_on(attribute)}</span>"
      end
      label_tag = content_tag 'label', label_text, :for => [object.class.to_s.underscore, attribute].join('_')

      content_tag 'div', label_tag + content, :class => classes.join(' ')
    end

    def labelled_text_field(attribute, label_text=nil, options={})
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.text_field(attribute, options), label_text)
    end

    def labelled_text_area(attribute, label_text=nil, options={})
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.text_area(attribute, options), label_text)
    end

    def labelled_date_select(attribute, label_text=nil, options={})
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.date_select(attribute, options), label_text)
    end

    def labelled_datetime_select(attribute, label_text=nil, options={})
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.datetime_select(attribute, options), label_text)
    end

    def labelled_time_select(attribute, label_text=nil, options={})
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.time_select(attribute, options), label_text)
    end

    def labelled_select(attribute, choices, label_text=nil, options={})
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.select(attribute, choices, options), label_text)
    end

    def labelled_check_box(attribute, label_text=nil, options={}, checked_value="1", unchecked_value="0")
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.check_box(attribute, options, checked_value, unchecked_value), label_text)
    end

    def labelled_file_field(attribute, label_text=nil, options={})
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.file_field(attribute, options), label_text)
    end

    def labelled_password_field(attribute, label_text=nil, options={})
      label_text, options = parse_label_text_and_options(label_text, options)
      field_with_label(attribute, self.password_field(attribute, options), label_text)
    end

    protected

      def parse_label_text_and_options(label_text=nil, options={})
        if label_text.kind_of?(Hash) && options == {}
          options = label_text
          label_text = nil
        end
        [label_text, options]
      end

  end
end
