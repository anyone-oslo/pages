# encoding: utf-8

module PagesCore
  module Templates
    class ConfigurationHandler
      class << self
        def handle(method_name, &handle_block)
          @@handle_blocks ||= {}
          @@handle_blocks[method_name] = handle_block
        end
        def default_handler(&handle_block)
          @@default_handler = handle_block
        end
      end

      attr_reader :configuration

      def initialize
        @configuration = {}
      end

      def method_missing(method_name, *args, &block)
        if @@handle_blocks && @@handle_blocks.keys.include?(method_name)
          proxy = PagesCore::Templates::ConfigurationProxy.new(@@handle_blocks[method_name], self)
          block.call(proxy) if block
          proxy
        elsif @@default_handler
          @@default_handler.call(self, method_name, *args)
        else
          super
        end
      end

      def proxy(proxy_block=nil, &callback)
        proxy_object = PagesCore::Templates::ConfigurationProxy.new(callback)
        proxy_block.call(proxy_object) if proxy_block
        proxy_object
      end

      def set(stack, value)
        @configuration ||= {}
        value = true  if value == :enabled
        value = false if value == :disabled
        stack = [stack] unless stack.kind_of?(Enumerable)
        partial_hash = stack.reverse.inject(value) do |hash, key|
          Hash[key => hash]
        end
        @configuration = @configuration.deep_merge(partial_hash)
        value
      end

      def get(*path)
        @configuration ||= {}
        path.inject(@configuration){ |value, key| (value && value.kind_of?(Hash) && value.has_key?(key)) ? value[key] : nil }
      end

    end
  end
end