# encoding: utf-8

module PagesCore
  class AdminMenuItem
    attr_reader :label, :path, :group, :options

    class << self
      def items
        return [] unless @menu_items
        @menu_items.map { |_, v| v }
      end

      def register(label, path, group = :custom, options = {})
        entry = new(label, path, group, options)
        @menu_items ||= {}
        @menu_items[[group, label]] = entry
      end
    end

    def initialize(label, path, group = :custom, options = {})
      @label, @path, @group, @options = label, path, group, options
    end

    def ==(other)
      other.label == label &&
        other.path == path &&
        other.group == group &&
        other.options == options
    end
  end
end
