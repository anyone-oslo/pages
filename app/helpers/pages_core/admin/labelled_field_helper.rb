# frozen_string_literal: true

module PagesCore
  module Admin
    module LabelledFieldHelper
      # Generate HTML for a field, with label and optionally description
      # and errors.
      #
      # The options are:
      # * <tt>:description</tt>: Description of the field
      # * <tt>:errors</tt>:      Error messages for the attribute
      #
      # An example:
      #   <%= form_for @user do |f| %>
      #     <%= labelled_field f.text_field(:username), "Username",
      #                        description: "Choose your username",
      #                        errors: @user.errors[:username] %>
      #     <%= submit_tag "Save" %>
      #   <% end %>
      #
      def labelled_field(field, label, options = {})
        tag.div(class: labelled_field_class(options)) do
          safe_join(
            [labelled_field_label(label, options),
             labelled_field_description(options[:description]),
             field,
             options[:check_box_description] || ""]
          )
        end
      end

      def image_upload_field(form, label, method = :image, options = {})
        output = ""
        if form.object.send(method)
          output += tag.p(dynamic_image_tag(form.object.send(method),
                                            size: "120x100"))
        end
        output + labelled_field(
          form.file_field(method),
          label, { errors: form.object.errors[method] }.merge(options)
        )
      end

      private

      def labelled_field_class(options = {})
        if options[:errors]&.any?
          "field field-with-errors"
        else
          "field"
        end
      end

      def labelled_field_label(label, options = {})
        tag.label do
          safe_join([label, labelled_field_errors(options[:errors])], " ")
        end
      end

      def labelled_field_description(str)
        return "" unless str

        tag.p(str, class: "description")
      end

      def labelled_field_errors(errors)
        return "" unless errors&.any?

        tag.span(class: "error") { Array(errors).last }
      end
    end
  end
end
