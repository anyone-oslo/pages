# encoding: utf-8

module PagesCore
  module Templates
    class ConfigurationHandler
      class << self
        def handle_blocks
          @handle_blocks ||= {}
        end

        def handle(method_name, &handle_block)
          @handle_blocks ||= {}
          @handle_blocks[method_name] = handle_block
        end
      end

      attr_reader :configuration

      def initialize
        @configuration = {}
      end

      def method_missing(method_name, *args, &block)
        if self.class.handle_blocks.keys.include?(method_name)
          proxy = PagesCore::Templates::ConfigurationProxy.new(
            self.class.handle_blocks[method_name],
            self
          )
          yield(proxy) if block
          proxy
        else
          super
        end
      end

      def proxy(proxy_block = nil, &callback)
        proxy_object = PagesCore::Templates::ConfigurationProxy.new(callback)
        proxy_block.call(proxy_object) if proxy_block
        proxy_object
      end

      def respond_to_missing?(method_name)
        self.class.handle_blocks.keys.include?(method_name)
      end

      def set(stack, value)
        @configuration ||= {}
        value = true  if value == :enabled
        value = false if value == :disabled
        stack = [stack] unless stack.is_a?(Enumerable)
        partial_hash = stack.reverse.inject(value) do |hash, key|
          Hash[key => hash]
        end
        @configuration = @configuration.deep_merge(partial_hash)
        value
      end

      def get(*path)
        @configuration ||= {}
        path.inject(@configuration) do |value, key|
          value && value.is_a?(Hash) && value.key?(key) ? value[key] : nil
        end
      end
    end
  end
end
