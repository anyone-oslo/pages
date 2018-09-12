module PagesCore
  module TemplateBlocks
    extend ActiveSupport::Concern

    module ClassMethods
      def block_ids
        templates.map(&:new).flat_map(&:block_ids).uniq
      end

      def blocks
        @blocks ||= {}
      end

      def block(name, definition = {})
        blocks[name] = { size: :small }.merge(definition)
      end

      def block_definition(name)
        return blocks[name] if blocks.key?(name)
        if superclass.respond_to?(:block_definition)
          return superclass.block_definition(name)
        end
        default_block_definitions[name]
      end

      def default_block_definitions
        { name:     { size: :field },
          headline: { size: :field },
          excerpt:  { size: :small },
          body:     { size: :large },
          boxout:   { size: :small } }
      end

      def localization?(block, name)
        if I18n.exists?("templates.#{id}.#{block}.#{name}")
          true
        elsif superclass.respond_to?(:localization?)
          superclass.localization?(block, name)
        elsif I18n.exists?("templates.default.#{block}.#{name}")
          true
        else
          false
        end
      end

      def localization(block, name)
        if I18n.exists?("templates.#{id}.#{block}.#{name}")
          I18n.t("templates.#{id}.#{block}.#{name}")
        elsif superclass.respond_to?(:localization)
          superclass.localization(block, name)
        else
          I18n.t("templates.default.#{block}.#{name}")
        end
      end
    end

    def block_ids
      return enabled_blocks if enabled_blocks.include?(:name)
      [:name] + enabled_blocks
    end

    def block_description(block)
      return nil unless self.class.localization?(block, :description)
      self.class.localization(block, :description)
    end

    def block_name(block)
      return block.to_s.humanize unless self.class.localization?(block, :name)
      self.class.localization(block, :name)
    end

    def block_placeholder(block)
      return nil unless self.class.localization?(block, :placeholder)
      self.class.localization(block, :placeholder)
    end

    def blocks
      block_ids.each_with_object({}) do |name, definitions|
        definitions[name] = self.class.block_definition(name)
      end
    end
  end
end
