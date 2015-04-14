# encoding: utf-8

module PagesCore
  module Templates
    class ConfigurationProxy
      def initialize(callback, parent = nil)
        @callback = callback
        @parent = parent
      end

      def method_missing(method_name, *args, &block)
        if @parent
          if block_given?
            @callback.call(@parent, method_name, block)
          else
            @callback.call(@parent, method_name, *args)
          end
        else
          if block_given?
            @callback.call(method_name, block)
          else
            @callback.call(method_name, *args)
          end
        end
      end
    end
  end
end
