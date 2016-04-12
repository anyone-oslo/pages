# encoding: utf-8

module PagesCore
  module TemplateConverter
    class Base
      class << self
        def all_templates
          ["application"] + template_files
        end

        def template_files
          Dir.glob(Rails.root.join("app/views/pages/templates/*.html.erb"))
             .map { |f| File.basename(f, ".html.erb") }
             .reject { |f| f =~ /^_/ }
        end
      end

      attr_reader :name

      def initialize(name)
        @name = name
      end

      private

      def application?
        name.to_s == "application"
      end

      def block(name)
        { title: config.block(name)[:title],
          description: config.block(name)[:description],
          size: config.block(name)[:size] || :small }
      end

      def blocks(all = false)
        all_blocks = enabled_blocks.each_with_object({}) do |name, blocks|
          blocks[name] = block(name)
        end
        return all_blocks if all
        reject_blocks(
          all_blocks,
          PagesCore::Template.default_block_definitions.merge(default_blocks)
        )
      end

      def config
        PagesCore::Deprecated::Templates::TemplateConfiguration.new(name)
      end

      def default_blocks
        config.config.get(:default, :blocks)
      end

      def enabled_blocks
        config.enabled_blocks - [:name]
      end

      def predefined_blocks
        [:meta_title, :meta_description,
         :open_graph_title, :open_graph_description]
      end
    end
  end
end
