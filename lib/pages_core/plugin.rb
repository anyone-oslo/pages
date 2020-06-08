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

      def migrations
        plugins.map { |p| p.new.migrations }.flatten.compact
      end

      def removed_migrations
        plugins.map { |p| p.new.removed_migrations }.flatten.compact
      end

      def existing_removed_migrations
        removed_migrations
          .select { |m| File.exist?(Rails.root.join("db", "migrate", m)) }
      end

      def existing_migrations
        migrations
          .map { |m| Rails.root.join("db", "migrate", m.basename) }
          .select { |m| File.exist?(m) }
      end

      def remove_old_migrations!
        (existing_removed_migrations + existing_migrations).each do |migration|
          File.unlink Rails.root.join("db", "migrate", migration)
        end
      end

      private

      def default_paths
        {
          "db/migrate" => "db/migrate",
          "config/removed_migrations.yml" => "config/removed_migrations.yml"
        }
      end
    end

    def root
      @root ||= find_root_with_subfolder("app")
    end

    def paths
      self.class.paths
    end

    def migrations_path
      root.join(paths["db/migrate"])
    end

    def removed_migrations_path
      root.join(paths["config/removed_migrations.yml"])
    end

    def migrations?
      File.exist?(migrations_path) && File.directory?(migrations_path)
    end

    def migrations
      Dir.entries(migrations_path)
         .select { |f| f =~ /\.rb$/ }
         .map { |f| migrations_path.join(f) }
    end

    def removed_migrations
      return unless File.exist?(removed_migrations_path)

      YAML.load_file(removed_migrations_path)
    end

    protected

    def find_root_with_subfolder(subfolder)
      root_path = self.class.called_from

      while root_path && File.directory?(root_path) &&
            !File.exist?("#{root_path}/#{subfolder}")
        parent = File.dirname(root_path)
        root_path = parent != root_path && parent
      end

      unless File.exist?("#{root_path}/#{subfolder}")
        raise "Could not find root path for #{self}"
      end

      Pathname.new(root_path).realpath
    end
  end
end
