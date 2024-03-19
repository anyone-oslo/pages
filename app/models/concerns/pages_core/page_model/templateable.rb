# frozen_string_literal: true

module PagesCore
  module PageModel
    module Templateable
      extend ActiveSupport::Concern

      included do
        before_validation :ensure_template

        delegate :enabled_blocks, to: :template_config
      end

      def template_config
        PagesCore::Templates::TemplateConfiguration.new(template)
      end

      def template
        return self[:template] if self[:template].present?

        inherited_or_default_template
      end

      def default_subtemplate
        template_config.value(:sub_template) ||
          default_template ||
          subtemplate_with_postfix ||
          singularized_subtemplate ||
          template
      end

      def unconfigured_blocks
        blocks = (localizations.where(locale:).pluck(:name)
                               .map(&:to_sym) -
                  configured_blocks) &
                 PagesCore::Templates::TemplateConfiguration.all_blocks

        if block_given?
          blocks.each do |block_name|
            yield block_name, template_config.block(block_name)
          end
        end

        blocks
      end

      private

      def configured_blocks
        enabled_blocks + %i[name path_segment meta_title meta_description
                            open_graph_title open_graph_description]
      end

      def singularized_subtemplate
        singularized = ActiveSupport::Inflector.singularize(base_template)
        return if base_template == singularized

        find_template_by_expression(
          Regexp.new("^#{Regexp.quote(singularized)}")
        )
      end

      def subtemplate_with_postfix
        find_template_by_expression(
          Regexp.new(
            "^#{Regexp.quote(base_template)}_?(post|page|subpage|item)"
          )
        )
      end

      def base_template
        reject_words = %w[index list archive liste arkiv]
        template.split("_")
                .reject { |w| reject_words.include?(w) }
                .join(" ")
      end

      def default_template
        configured = PagesCore::Templates.configuration.get(
          :default, :template, :value
        )
        configured if configured != :autodetect
      end

      def find_template_by_expression(expr)
        PagesCore::Templates.names
                            .select { |t| t.match(expr) }
                            .try(&:first)
      end

      def default_template_options
        PagesCore::Templates.configuration.get(
          :default, :template, :options
        ) || {}
      end

      def inherited_or_default_template
        return parent.default_subtemplate.to_s if parent

        (default_template_options[:root] || default_template || :index).to_s
      end

      def ensure_template
        self[:template] ||= inherited_or_default_template
      end
    end
  end
end
