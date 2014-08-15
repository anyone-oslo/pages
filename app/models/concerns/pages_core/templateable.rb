# encoding: utf-8

module PagesCore
  module Templateable
    extend ActiveSupport::Concern

    included do
      before_validation :ensure_template
    end

    def template_config
      PagesCore::Templates::TemplateConfiguration.new(self.template)
    end

    def template
      !self[:template].blank? ? self[:template] : default_template
    end

    def default_subtemplate
      tpl = nil
      default_template = PagesCore::Templates.configuration.get(:default, :template, :value)
      if self.template_config.value(:sub_template)
        tpl = self.template_config.value(:sub_template)
      elsif default_template && default_template != :autodetect
        tpl = default_template
      else
        # Autodetect sub template
        reject_words = ['index', 'list', 'archive', 'liste', 'arkiv']
        base_template = self.template.split(/_/).reject{|w| reject_words.include?(w) }.join(' ')
        tpl = PagesCore::Templates.names.select { |t| t.match(Regexp.new('^'+Regexp.quote(base_template)+'_?(post|page|subpage|item)')) }.first rescue nil
        # Try to singularize the base template if the subtemplate could not be found.
        unless tpl and base_template == ActiveSupport::Inflector::singularize(base_template)
          tpl = PagesCore::Templates.names.select{ |t| t.match(Regexp.new('^'+Regexp.quote(ActiveSupport::Inflector::singularize(base_template)))) }.first rescue nil
        end
      end
      # Inherit template by default
      tpl ||= self.template
    end

    private

    def default_template
      if self.parent
        t = self.parent.default_subtemplate
      else
        default_value   = PagesCore::Templates.configuration.get(:default, :template, :value)
        default_options = PagesCore::Templates.configuration.get(:default, :template, :options)
        if  default_options && default_options[:root]
          t = default_options[:root]
        elsif default_value && default_value != :autodetect
          t = default_value
        end
      end
      t ||= :index
      t.to_s
    end

    def ensure_template
      self[:template] ||= default_template
    end
  end
end