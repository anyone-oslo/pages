# frozen_string_literal: true

module PagesCore
  module Admin
    module LocalesHelper
      def locales_with_dir
        locales = PagesCore.config.locales || {}
        locales.each_with_object({}) do |(key, name), hash|
          hash[key] = { name:, dir: locale_direction(key) }
        end
      end

      def locale_direction(locale)
        rtl_locale?(locale) ? "rtl" : "ltr"
      end

      def rtl_locale?(locale)
        rtl_locales.include?(locale.to_s)
      end

      def rtl_locales
        %w[ar arc dv fa ha he khw ks ku ps ur yi]
      end
    end
  end
end
