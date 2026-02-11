# frozen_string_literal: true

# module PagesGallery
#  class Plugin < PagesCore::Plugin
#    paths['db/migrate'] = 'template/db/migrate'
#  end
# end

module PagesCore
  class Plugin
    class << self
      attr_accessor :called_from, :paths

      def inherited(plugin)
        plugin.paths ||= default_paths
        plugin.called_from = begin
          # Remove the line number from backtraces making sure we
          # don't leave anything behind
          call_stack = caller.map { |p| p.sub(/:\d+.*/, "") }
          File.dirname(
            call_stack.detect do |p|
              p !~ %r{railties[\w.-]*/lib/rails|rack[\w.-]*/lib/rack}
            end
          )
        end
        super
      end

      def admin_menu_item(label, path, group = :custom, options = {})
        PagesCore::AdminMenuItem.register(label, path, group, options)
      end

      def plugins
        @plugins ||= ::PagesCore::Plugin.subclasses.map do |class_name|
          class_name.to_s.split("::").inject(Object) do |klass, m|
            klass.const_get(m)
          end
        end
      end

      private

      def default_paths
        { "db/migrate" => "db/migrate" }
      end
    end

    def root
      @root ||= find_root_with_subfolder("app")
    end

    delegate :paths, to: :class

    protected

    def find_root_with_subfolder(subfolder)
      root_path = self.class.called_from

      while root_path && File.directory?(root_path) &&
            !File.exist?("#{root_path}/#{subfolder}")
        parent = File.dirname(root_path)
        root_path = parent != root_path && parent
      end

      raise "Could not find root path for #{self}" unless File.exist?("#{root_path}/#{subfolder}")

      Pathname.new(root_path).realpath
    end
  end
end
