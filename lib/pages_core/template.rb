module PagesCore
  class Template
    class << self
      def inherited(template)
        templates << template
      end

      def templates
        @templates ||= []
      end

      def blocks
        @blocks ||= {}
      end

      def configuration
        @configuration ||= {}
      end

      def block(name, definition = {})
        blocks[name] = definition
      end

      def block_definition(name)
        if blocks.key?(name)
          blocks[name]
        elsif superclass.respond_to?(:block_definition)
          superclass.block_definition(name)
        else
          default_block_definitions[name]
        end
      end

      def default_block_definitions
        {
          name:     { size: :field },
          headline: { size: :field },
          excerpt:  {},
          body:     { size: :large },
          boxout:   {}
        }
      end

      def default_configuration
        {
          enabled_blocks:   [:headline, :excerpt, :body],
          filename:         nil,
          comments:         false,
          comments_allowed: true,
          files:            false,
          images:           false,
          name:             nil,
          tags:             false
        }
      end

      def set(key, value, *extra)
        return configuration[key] = value unless extra.any?
        configuration[key] = [value] + extra
      end

      def name(new_name)
        set(:name, new_name)
      end

      def get(key)
        if configuration.key?(key)
          configuration[key]
        elsif superclass.respond_to?(:get)
          superclass.get(key)
        else
          default_configuration[key]
        end
      end

      private

      def method_missing(name, *args)
        if default_configuration.keys.include?(name)
          if args.empty?
            get(name)
          else
            set(name, *args)
          end
        else
          super
        end
      end
    end

    def block_names
      return enabled_blocks if enabled_blocks.include?(:name)
      [:name] + enabled_blocks
    end

    def blocks
      block_names.each_with_object({}) do |name, definitions|
        definitions[name] = self.class.block_definition(name)
      end
    end

    def filename
      self.class.get(:filename) || id.to_s
    end

    def id
      self.class.to_s.gsub(/Template$/, "").underscore.to_sym
    end

    def name
      return self.class.get(:name) if self.class.configuration.key?(:name)
      id.to_s.humanize
    end

    def path
      "pages/templates/#{filename}"
    end

    def method_missing(name, *args)
      key = name.to_s.gsub(/\?$/, "").to_sym
      if key?(key)
        if name.to_s =~ /\?$/
          self.class.get(key) ? true : false
        else
          self.class.get(key)
        end
      else
        super
      end
    end

    private

    def key?(key)
      self.class.default_configuration.key?(key)
    end
  end
end
