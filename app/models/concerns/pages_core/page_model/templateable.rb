# frozen_string_literal: true

module PagesCore
  module PageModel
    module Templateable
      extend ActiveSupport::Concern

      included do
        before_validation :ensure_template
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

      private

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
        template.split(/_/)
                .reject { |w| %w[index list archive liste arkiv].include?(w) }
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
