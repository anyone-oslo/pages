# encoding: utf-8

module PagesCore
  module Templates

    class TemplateConfiguration
      attr_reader :template_name

      def initialize(template_name)
        @template_name = template_name.to_sym
      end

      def config
        PagesCore::Templates.configuration
      end

      def value(*path)
        path = [path, :value].flatten
        value = config.get(*[:default, path].flatten)
        template_value = config.get(*[:templates, @template_name, path].flatten)
        if template_value != nil
          value = template_value
        end
        value
      end

      def options(*path)
        path = [path, :options].flatten
        options_hash = config.get(*[:default, path].flatten)
        options_hash ||= {}
        if template_hash = config.get(*[:templates, @template_name, path].flatten)
          options_hash = options_hash.deep_merge(template_hash)
        end
        options_hash
      end

      def block(block_name)
        block_options = {
          :title    => block_name.to_s.humanize,
          :optional => true,
          :size     => :small
        }
        if default_block_options = config.get(*[:default, :blocks, block_name])
          block_options = block_options.deep_merge(default_block_options)
        end
        if template_block_options = config.get(*[:templates, @template_name, :blocks, block_name])
          block_options = block_options.deep_merge(template_block_options)
        end
        block_options
      end

      def enabled_blocks
        blocks = self.value(:enabled_blocks)
        if block_given?
          blocks.each{|block_name| yield block_name, self.block(block_name)}
        end
        blocks
      end

      # Returns a list of all configured blocks
      def all_blocks
        all_templates = config.get(:templates).keys rescue []
        blocks = []
        blocks += config.get(:default, :enabled_blocks, :value)
        blocks += config.get(:default, :blocks).keys rescue []
        blocks += all_templates.map{|t| config.get(:templates, t, :enabled_blocks, :value)}
        blocks += all_templates.map{|t| config.get(:templates, t, :blocks).keys rescue []}
        blocks.flatten.compact.uniq
      end
    end

    class << self
      def configure(options={}, &block)
        if options[:reset] == :defaults
          load_default_configuration
        elsif options[:reset] === true
          @@configuration = PagesCore::Templates::Configuration.new
        end
        yield self.configuration if block_given?
      end

      def load_default_configuration
        @@configuration = PagesCore::Templates::Configuration.new

        # Default template options
        config.default do |default|
          default.template         :autodetect, :root => 'index'
          default.image            :enabled, :linkable => false
          default.comments         :enabled
          default.comments_allowed :enabled
          default.files            :disabled
          default.images           :disabled
          default.text_filter      :textile
          default.enabled_blocks   [:headline, :excerpt, :body]
          default.blocks do |block|
            block.body        "Body",        :size => :large
            block.headline    "Headline",    :description => 'Optional, use if the headline should differ from the page name.', :size => :field
            block.excerpt     "Standfirst",  :description => 'An introductory paragraph before the start of the body.'
             block.boxout      "Boxout",      :description => 'Part of the page, usually background info or facts related to the article.'
          end
        end
      end

      def configuration
        load_default_configuration unless self.class_variables.include?('@@configuration')
        @@configuration
      end
      alias :config :configuration
    end

  end
end
