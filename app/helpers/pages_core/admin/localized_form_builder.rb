# frozen_string_literal: true

module PagesCore
  module Admin
    module LocalizedFormBuilder
      include PagesCore::Admin::LocalesHelper

      def text_area(method, options = {})
        super(method, localized_form_field_options(method).merge(options))
      end

      def text_field(method, options = {})
        super(method, localized_form_field_options(method).merge(options))
      end

      private

      def localized_form_field_options(method)
        unless object.is_a?(LocalizableModel::InstanceMethods) &&
               object.class.localized_attributes.include?(method.to_sym)
          return {}
        end

        { dir: rtl_locale?(object.locale) ? "rtl" : "ltr",
          lang: object.locale }
      end
    end
  end
end
