# encoding: utf-8

module PagesCore
  module Templates
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
        [
          :template, :image, :images, :files, :text_filter, :blocks,
          :enabled_blocks, :sub_template, :comments, :comments_allowed, :tags
        ]
      end

      def configure_block(tpl_name, block_name, title = false, options = {})
        block_name = block_name.to_sym
        title ||= block_name.to_s.humanize
        options[:title] = title
        if tpl_name == :_defaults
          set([:default, :blocks, block_name], options)
        else
          set([:templates, tpl_name, :blocks, block_name], options)
        end
      end

      def configure_template(template_name, setting, value, options = {})
        template_name = template_name.to_sym
        setting = setting.to_sym
        if valid_template_options.include?(setting)
          value = true  if value == :enabled
          value = false if value == :disabled
          template_config = {
            setting => {
              value:   value,
              options: options
            }
          }
          if template_name == :_defaults
            set([:default], template_config)
          else
            set([:templates, template_name], template_config)
          end
        else
          fail "Invalid template configuration value: #{setting.inspect}"
        end
      end

      def blocks(template_name = :_defaults, &block)
        proxy(block) do |name, *args|
          configure_block(template_name, name, *args)
        end
      end

      def templates(*tpl_args, &block)
        template_names = tpl_args.flatten.map(&:to_sym)
        proxy(block) do |name, *args|
          if name == :blocks
            proxy(args.first.is_a?(Proc) ? args.first : nil) do |n2, *a2|
              template_names.each do |template_name|
                configure_block(template_name, n2, *a2)
              end
            end
          else
            template_names.each do |template_name|
              configure_template(template_name, name, *args)
            end
          end
        end
      end
      alias_method :template, :templates
    end
  end
end
