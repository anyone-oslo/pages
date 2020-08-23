# frozen_string_literal: true

module PagesCore
  module Templates
    # = Template configuration
    #
    # Configuration DSL for the page templates. Can be accessed through
    # +PagesCore::Templates.configure+.
    #
    #   PagesCore::Templates.configure do |config|
    #     # Configuration goes here
    #   end
    #
    # == Configuring templates
    #
    # Defaults for all templates can be configured with:
    #
    #   config.default do |default|
    #     default.enabled_blocks %i[name headline body]
    #     default.files :disabled
    #   end
    #
    # Individual template configurations override the defaults.
    #
    #   config.template(:article, :article_alt) do |t|
    #     t.enabled_blocks %i[name headline excerpt body boxout]
    #     t.files :enabled
    #   end
    #
    # == Options
    #
    # [blocks]
    #   Yields the block configuration.
    # [enabled_blocks]
    #   List of enabled blocks. Default: +%i[headline excerpt body]+
    # [template]
    #   Template for all pages, unless overridden with +sub_template+.
    #   It will attempt to guess based on the parent page if set to
    #   +:autodetect+, which is the default value. Pass the +:root+
    #   option to set template at root level.
    # [image]
    #   Enable images. Default: +:enabled+
    # [files]
    #   Enable file uploads. Default: +:disabled+
    # [tags]
    #   Enable tags. Default: +:disabled+
    # [dates]
    #   Enable dates. Default: +:disabled+
    # [sub_template]
    #   Children of the page will automatically have this template if
    #   configured. Defaults to +nil+, which fall back to the behaviour
    #   of +template+.
    #
    # == Block configuration
    #
    # Blocks can be configured at top level, or per template:
    #
    #   config.default do |default|
    #     default.blocks do |block|
    #       block.byline("Byline", size: :field)
    #       block.embed("Video embed", size: :small, description: "Embed code")
    #     end
    #     default.enabled_blocks %i[headline byline body embed]
    #   end
    #
    # Valid sizes for text blocks are +:field+ (single line), +:small+
    # and +:large+.
    #
    # === Select blocks
    #
    # Blocks can also be selects:
    #
    #   block.foobar("Foobar", type: :select, options: %w[Foo Bar Baz])
    #
    # Pass a hash for multiple localizations:
    #
    #   block.foobar("Foobar", type: :select,
    #                options: { en: %w[Foo Bar Baz],
    #                           nb: %w[Fuu Baer Baez] })
    #
    # Options can be set at runtime using a Proc:
    #
    #   block.foobar("Foobar", type: :select,
    #                options: -> { FooBar.template_options })
    class Configuration < PagesCore::Templates::ConfigurationHandler
      handle :default do |instance, name, *args|
        if name == :blocks
          blocks_proxy = instance.blocks
          args.first.call(blocks_proxy) if args.first.is_a?(Proc)
          blocks_proxy
        else
          instance.configure_template(:_defaults, name, *args)
        end
      end

      def valid_template_options
        %i[template image images files text_filter blocks
           enabled_blocks sub_template tags dates]
      end

      def configure_block(tpl_name, block_name, title = nil, options = {})
        block_name = block_name.to_sym
        opts = {
          title: title || block_name.to_s.humanize,
          localized: true
        }.merge(options)
        if tpl_name == :_defaults
          set([:default, :blocks, block_name], opts)
        else
          set([:templates, tpl_name, :blocks, block_name], opts)
        end
      end

      def configure_template(template_name, setting, value, options = {})
        template_name = template_name.to_sym
        setting = setting.to_sym
        unless valid_template_options.include?(setting)
          raise "Invalid template configuration value: #{setting.inspect}"
        end

        set(
          template_path(template_name),
          template_config(setting, value, options)
        )
      end

      def blocks(template_name = :_defaults, &block)
        proxy(block) do |name, *args|
          configure_block(template_name, name, *args)
        end
      end

      def templates(*tpl_args, &block)
        names = tpl_args.flatten.map(&:to_sym)
        proxy(block) do |name, *args|
          if name == :blocks
            proxy(args.first.is_a?(Proc) ? args.first : nil) do |n2, *a2|
              names.each { |t| configure_block(t, n2, *a2) }
            end
          else
            names.each { |t| configure_template(t, name, *args) }
          end
        end
      end
      alias template templates

      private

      def template_config(setting, value, options)
        value = true if value == :enabled
        value = false if value == :disabled
        { setting => { value: value, options: options } }
      end

      def template_path(name)
        return [:default] if name == :_defaults

        [:templates, name]
      end
    end
  end
end
