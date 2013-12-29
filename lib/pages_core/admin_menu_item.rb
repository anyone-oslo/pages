module PagesCore
  class AdminMenuItem
    attr_reader :label, :path, :group, :options

    class << self
      def items
        @@items ||= []
      end

      def register(label, path, group=:custom, options={})
        entry = self.new(label, path, group, options)
        items << entry unless items.include?(entry)
      end
    end

    def initialize(label, path, group=:custom, options={})
      @label, @path, @group, @options = label, path, group, options
    end
  end
end