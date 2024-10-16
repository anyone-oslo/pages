# frozen_string_literal: true

module PagesCore
  module Templates
    class ConfigurationProxy
      def initialize(callback, parent = nil)
        @callback = callback
        @parent = parent
      end

      def method_missing(method_name, *, &block)
        if @parent && block
          @callback.call(@parent, method_name, block)
        elsif @parent
          @callback.call(@parent, method_name, *)
        elsif block
          @callback.call(method_name, block)
        else
          @callback.call(method_name, *)
        end
      end

      def respond_to_missing?
        true
      end
    end
  end
end
