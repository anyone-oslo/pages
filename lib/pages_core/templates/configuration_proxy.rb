# frozen_string_literal: true

module PagesCore
  module Templates
    class ConfigurationProxy
      def initialize(callback, parent = nil)
        @callback = callback
        @parent = parent
      end

      def method_missing(method_name, *args, &block)
        if @parent && block
          @callback.call(@parent, method_name, block)
        elsif @parent
          @callback.call(@parent, method_name, *args)
        elsif block
          @callback.call(method_name, block)
        else
          @callback.call(method_name, *args)
        end
      end

      def respond_to_missing?
        true
      end
    end
  end
end
