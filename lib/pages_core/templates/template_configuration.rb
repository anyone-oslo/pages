# encoding: utf-8

module PagesCore
  module Templates
    class TemplateConfiguration
      attr_reader :template_name

      class << self
        def all_blocks
          new(:index).all_blocks
        end
      end

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
        value = template_value unless template_value.nil?
        value
      end

      def options(*path)
        path = [path, :options].flatten
        (config.get(*[:default, path].flatten) || {})
          .deep_merge(
            config.get(*[:templates, @template_name, path].flatten) || {}
          )
      end

      def block(block_name)
        default_block_options(block_name)
          .deep_merge(config.get(*[:default, :blocks, block_name]) || {})
          .deep_merge(
            config.get(*[:templates, @template_name, :blocks, block_name]) || {}
          )
      end

      def enabled_blocks
        blocks = value(:enabled_blocks)
        blocks = [:name] + blocks unless blocks.include?(:name)
        if block_given?
          blocks.each { |block_name| yield block_name, block(block_name) }
        end
        blocks
      end

      def metadata_blocks
        blocks = PagesCore::Templates.metadata_block_names
        if block_given?
          blocks.each { |block_name| yield block_name, block(block_name) }
        end
        blocks
      end

      # Returns a list of all configured blocks
      def all_blocks
        (
          all_templates.map { |t| configured_block_names(t) } +
            all_templates.map { |t| enabled_block_names(t) }
        ).flatten.compact.uniq
      end

      private

      def configured_block_names(template)
        Array(config.get(:default, :blocks).try(&:keys)) +
          Array(config.get(:templates, template, :blocks).try(&:keys))
      end

      def enabled_block_names(template)
        Array(config.get(:default, :enabled_blocks, :value)) +
          Array(config.get(:templates, template, :enabled_blocks, :value))
      end

      def default_block_options(block_name)
        {
          title:    block_name.to_s.humanize,
          optional: true,
          size:     :small
        }
      end

      def all_templates
        Array(config.get(:templates).try(&:keys))
      end
    end

    class << self
      def configure(options = {}, &_block)
        if options[:reset] == :defaults
          load_default_configuration
        elsif options[:reset] == true
          @configuration = PagesCore::Templates::Configuration.new
        end
        yield configuration if block_given?
      end

      def load_default_configuration
        @configuration = PagesCore::Templates::Configuration.new

        # Default template options
        config.default do |default|
          default.template :autodetect, root: "index"
          default.image :enabled, linkable: false
          default.comments :disabled
          default.comments_allowed :enabled
          default.files :disabled
          default.images :disabled
          default.text_filter :textile
          default.enabled_blocks [:headline, :excerpt, :body]
          default.tags :disabled
          default_block_configuration(default)
        end
      end

      def configuration
        load_default_configuration unless defined? @configuration
        @configuration
      end
      alias_method :config, :configuration

      def metadata_block_names
        [
          :meta_title,
          :meta_description,
          :open_graph_title,
          :open_graph_description
        ]
      end

      private

      def default_block_configuration(default)
        default.blocks do |block|
          block.name(
            "Name",
            size: :field,
            description: "This is the name of the page, and it will also " \
              "be the name of the link to this page.",
            class: "page_title"
          )
          block.body(
            "Body",
            size: :large
          )
          block.headline(
            "Headline",
            description: "Optional, use if the headline should differ from " \
              "the page name.",
            size: :field
          )
          block.excerpt(
            "Standfirst",
            description: "An introductory paragraph before the start " \
              "of the body."
          )
          block.boxout(
            "Boxout",
            description: "Part of the page, usually background info or " \
              "facts related to the article."
          )
          block.meta_title(
            "Title",
            size: :field,
            description: "Document title. Will fall back to the page name " \
              "if empty. Recommended length: Up to 56 characters."
          )
          block.meta_description(
            "Description",
            size: :small,
            description: "Description for search engines. Will fall back to " \
              "Standfirst if empty. Recommended length: Up to 156 characters."
          )
          block.open_graph_title(
            "Open Graph Title",
            size: :field,
            description: "Page title for Facebook sharing. Will fall back to " \
              "the document title."
          )
          block.open_graph_description(
            "Open Graph Description",
            size: :small,
            description: "Description for Facebook sharing. Will fall back " \
              "to Description or Standfirst if empty."
          )
        end
      end
    end
  end
end
