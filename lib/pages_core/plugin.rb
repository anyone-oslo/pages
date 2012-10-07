#module PagesGallery
#  class Plugin < PagesCore::Plugin
#    paths['db/migrate'] = 'template/db/migrate'
#  end
#end

module PagesCore
  class Plugin

    class << self
      attr_accessor :called_from, :paths

      def inherited(plugin)
        plugin.paths ||= {
          'db/migrate' => 'db/migrate'
        }
        plugin.called_from = begin
          # Remove the line number from backtraces making sure we don't leave anything behind
          call_stack = caller.map { |p| p.sub(/:\d+.*/, '') }
          File.dirname(call_stack.detect { |p| p !~ %r[railties[\w.-]*/lib/rails|rack[\w.-]*/lib/rack] })
        end
      end

      def plugins
        @plugins ||= ::PagesCore::Plugin.subclasses.map do |class_name|
          class_name.to_s.split("::").inject(Object) do |klass, m|
            klass = klass.const_get(m)
          end
        end
      end

      def migrations
        plugins.map{|p| p.new.migrations}.flatten.compact
      end

      def new_migrations
        migrations.reject{|m| File.exists?(Rails.root.join('db', 'migrate', m.basename))}
      end

      def mirror_migrations!
        new_migrations.each do |migration|
          FileUtils.cp migration, Rails.root.join('db', 'migrate')
        end
      end
    end

    def root
      @root ||= find_root_with_flag('app')
    end

    def paths
      self.class.paths
    end

    def migrations_path
      root.join(paths['db/migrate'])
    end

    def has_migrations?
      File.exists?(migrations_path) && File.directory?(migrations_path)
    end

    def migrations
      Dir.entries(migrations_path).select{|f| f =~ /\.rb$/}.map{|f| migrations_path.join(f)}
    end

    protected

      def find_root_with_flag(flag, default=nil)
        root_path = self.class.called_from

        while root_path && File.directory?(root_path) && !File.exist?("#{root_path}/#{flag}")
          parent = File.dirname(root_path)
          root_path = parent != root_path && parent
        end

        root = File.exist?("#{root_path}/#{flag}") ? root_path : default
        raise "Could not find root path for #{self}" unless root

        RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ ?
          Pathname.new(root).expand_path : Pathname.new(root).realpath
      end

  end
end