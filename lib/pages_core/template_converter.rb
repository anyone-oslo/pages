# encoding: utf-8

load "pages_core/template_converter/base.rb"
load "pages_core/template_converter/generator.rb"
load "pages_core/template_converter/localizer.rb"

module PagesCore
  module TemplateConverter
    class << self
      def convert!
        in_locale(:en) do
          Generator.run!
          Localizer.run!
        end
      end

      private

      def in_locale(locale)
        prev_locale = I18n.locale
        I18n.locale = locale
        result = yield
        I18n.locale = prev_locale
        result
      end
    end
  end
end
