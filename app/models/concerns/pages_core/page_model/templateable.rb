module PagesCore
  module PageModel
    module Templateable
      extend ActiveSupport::Concern

      included do
        before_validation :ensure_template
      end

      def template_config
        PagesCore::Template.find(template).new
      end

      def template
        return self[:template] if self[:template].present?
        inherited_or_default_template
      end

      def default_subtemplate
        template_config.subtemplate || template
      end

      private

      def ensure_template
        self[:template] ||= inherited_or_default_template
      end

      def inherited_or_default_template
        return parent.default_subtemplate if parent
        (ApplicationTemplate.new.subtemplate || :index).to_s
      end
    end
  end
end
