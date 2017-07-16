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
          .deep_merge(config.get(:default, :blocks, block_name) || {})
          .deep_merge(
            config.get(:templates, @template_name, :blocks, block_name) || {}
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
          default_configuration(default)
          default_block_configuration(default)
        end
      end

      def configuration
        load_default_configuration unless defined? @configuration
        @configuration
      end
      alias config configuration

      def metadata_block_names
        %i[
          meta_title
          meta_description
          open_graph_title
          open_graph_description
        ]
      end

      private

      def default_configuration(config)
        config.template :autodetect, root: "index"
        config.image :enabled, linkable: false
        config.files :disabled
        config.images :disabled
        config.text_filter :textile
        config.enabled_blocks %i[headline excerpt body]
        config.tags :disabled
      end

      def default_blocks
        {
          name:     { size: :field, class: "page_title" },
          body:     { size: :large },
          headline: { size: :field },
          excerpt:  {},
          boxout:   {}
        }.merge(default_meta_blocks)
      end

      def default_meta_blocks
        {
          meta_title:             { size: :field },
          meta_description:       { size: :small },
          open_graph_title:       { size: :field },
          open_graph_description: { size: :small }
        }
      end

      def default_block_configuration(default)
        default.blocks do |block|
          default_blocks.keys.each do |name|
            block.send(
              name,
              template_block_localization("#{name}.name"),
              default_block_options(name)
            )
          end
        end
      end

      def default_block_options(name)
        {
          description: template_block_localization("#{name}.description")
        }.merge(default_blocks[name])
      end

      def template_block_localization(str)
        # Templates are configured in an initializer, and
        # localizations aren't usually configured at this time. This
        # forces loading of localizations from the plugin.
        PagesCore::PagesPlugin.configure_localizations!

        I18n.t("templates.default.blocks.#{str}")
      end
    end
  end
end
