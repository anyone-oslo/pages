module PagesCore
  module PageModel
    module Localizable
      include ActiveSupport::Inflector
      extend ActiveSupport::Concern

      included do
        localizable do
          attribute :name
          attribute :body
          attribute :excerpt
          attribute :headline
          attribute :boxout

          attribute :path_segment
          attribute :meta_title
          attribute :meta_description
          attribute :open_graph_title
          attribute :open_graph_description

          dictionary(lambda do
            PagesCore::Templates::TemplateConfiguration.all_blocks
          end)
        end
      end

      def transliterated_name
        transliterate_value(name)
      end

      def transliterate_value(str)
        prev_locale = I18n.locale
        I18n.locale = locale.to_sym if locale
        transliterated = transliterate(str)
        I18n.locale = prev_locale
        transliterated
      end
    end
  end
end
