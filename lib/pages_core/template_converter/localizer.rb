# encoding: utf-8

module PagesCore
  module TemplateConverter
    class Localizer < PagesCore::TemplateConverter::Base
      class << self
        def run!
          write_localizations(localizations.deep_merge(existing))
        end

        private

        def existing
          return {} unless File.exist?(localization_file)
          YAML.load_file(localization_file)
        end

        def localization_file
          Rails.root.join("config", "locales", "en.yml")
        end

        def localizations
          all_templates.inject({}) { |a, e| a.deep_merge(new(e).foo) }
        end

        def write_localizations(localizations)
          File.open(localization_file, "w") do |fh|
            fh.write(localizations.to_yaml)
          end
        end
      end

      def foo
        return {} if cleaned.blank?
        ns = application? ? "default" : name.to_s
        { "en" => { "templates" => {
          ns => cleaned
        } } }
      end

      private

      def clean(hash)
        hash.reject { |_, v| v.blank? }
      end

      def cleaned
        if application?
          clean(default_localizations)
        else
          clean(template_localizations)
        end
      end

      def map_blocks(blocks)
        blocks
          .reject { |k, _| predefined_blocks.include?(k) }
          .each_with_object({}) do |(block, v), hash|
            hash[block.to_s] = {
              "name" => v[:title], "description" => v[:description]
            }.reject do |key, str|
              str.blank? || yield(block.to_s, key, str)
            end
          end
      end

      def default_localization(block, key)
        return nil unless default_localizations[block]
        default_localizations[block][key]
      end

      def default_localizations
        map_blocks(default_blocks) do |block, key, str|
          (key == "name" && str == block.humanize) ||
            str == I18n.t("templates.default.#{block}.#{key}")
        end
      end

      def template_localizations
        map_blocks(blocks(true)) do |block, key, str|
          (key == "name" && str == block.humanize) ||
            str == default_localization(block, key) ||
            str == I18n.t("templates.#{name}.#{block}.#{key}") ||
            str == I18n.t("templates.default.#{block}.#{key}")
        end
      end
    end
  end
end
