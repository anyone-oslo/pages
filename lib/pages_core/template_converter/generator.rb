# encoding: utf-8

module PagesCore
  module TemplateConverter
    class Generator < PagesCore::TemplateConverter::Base
      class << self
        def run!
          all_templates.each { |n| new(n).generate! }
        end
      end

      def generate!
        if application?
          run_generator(default_template_blocks, default_template_options)
        else
          run_generator(template_blocks, template_options)
        end
      end

      private

      def default_config(key)
        config.config.get(:default, key)[:value]
      end

      def default_subtemplate
        return nil if default_config(:template) == :autodetect
        default_config(:template)
      end

      def default_template_blocks
        reject_blocks(
          default_blocks,
          PagesCore::Template.default_block_definitions
        ).map { |n, o| "#{n}:#{o[:size] || 'small'}" }
      end

      def default_template_options
        { enabled_blocks: default_config(:enabled_blocks).join(","),
          comments: default_config(:comments),
          comments_allowed: default_config(:comments_allowed),
          images: default_config(:images) || default_config(:image),
          tags: default_config(:tags),
          subtemplate: default_subtemplate,
          parent: "PagesCore::Template" }
      end

      def run_generator(blocks, options)
        Rails::Generators.invoke(
          "pages_core:template",
          [name, blocks, *generator_args(options.merge(view: false))]
        )
      end

      def generator_args(hash)
        hash.map { |name, value| "--#{name.to_s.dasherize}=#{value}" }
      end

      def images?
        config.value(:images) || config.value(:image)
      end

      def reject_blocks(blocks, defs)
        blocks
          .reject { |k, _| predefined_blocks.include?(k) }
          .reject do |k, v|
            defs.key?(k) && defs[k][:size] == (v[:size] ||= :small)
          end
      end

      def template_blocks
        (blocks.map { |n, o| "#{n}:#{o[:size]}" } - default_template_blocks)
      end

      def template_options
        {
          enabled_blocks: enabled_blocks.join(","),
          comments: config.value(:comments),
          comments_allowed: config.value(:comments_allowed),
          images: images?,
          tags: config.value(:tags),
          subtemplate: config.value(:sub_template)
        }.reject { |k, v| default_template_options[k] == v }
      end
    end
  end
end
