# encoding: utf-8

module PagesCore
  class CacheSweeper
    class << self
      attr_accessor :enabled

      def disable(&_block)
        old_value = enabled
        self.enabled = false
        yield
        self.enabled = old_value
      end

      def once(&block)
        disable(&block)
        PagesCore::SweepCacheJob.perform_later
      end

      # Returns the default configuration.
      def default_config
        OpenStruct.new(
          cache_path: ActionController::Base.page_cache_directory,
          observe: [Page, PageComment, Image],
          patterns: [
            /^\/index\.[\w]+$/,
            %r{^/pages/[\w]{2,3}[/\.](.*)$},
            %r{^/[\w]{2,3}/(.*)$}
          ]
        )
      end

      # Returns the configuration. Accepts a block, ie:
      #
      #   PagesCore::CacheSweeper.config do |c|
      #     c.observe  += [:store, :store_test]
      #     c.patterns += [/^\/arkiv(.*)$/, /^\/tests(.*)$/]
      #   end
      def config
        @configuration ||= default_config
        if block_given?
          yield @configuration
          extend_observed_models!
        end
        @configuration
      end

      def extend_observed_models!
        config.observe.each do |klass|
          if klass.is_a?(Symbol) || klass.is_a?(String)
            klass = klass.to_s.camelize.constantize
          end
          unless klass.include?(PagesCore::Sweepable)
            klass.send(:include, PagesCore::Sweepable)
          end
        end
      end

      # Purge the entire pages cache
      def purge!
        cache_dir = config.cache_path
        `rm -rf "#{cache_dir}/*"` if File.exist?(cache_dir)
      end

      # Sweep all cached pages
      def sweep!
        return [] unless enabled
        cache_dirs.flat_map { |d| sweep_dir(d)  }
      end

      private

      def cache_dirs
        if PagesCore.config(:domain_based_cache)
          Dir.entries(config.cache_path)
            .select { |d| visible_dir?(d) }
            .map { |d| File.join(config.cache_path, d) }
            .map(&:to_s)
        else
          [config.cache_path.to_s]
        end
      end

      def visible_dir?(dir)
        !(dir =~ /^\./) && File.directory?(File.join(config.cache_path, dir))
      end

      def sweep_dir(cache_dir)
        return [] unless File.exist?(cache_dir)
        swept_files = []
        Find.find(cache_dir + "/") do |path|
          Find.prune if skip_path?(cache_dir, path)
          file = path.gsub(Regexp.new("^#{cache_dir}"), "")
          config.patterns.each do |p|
            if file =~ p && File.exist?(path)
              swept_files << path
              FileUtils.rm_rf(path)
            end
          end
        end
        swept_files
      end

      def skip_path?(cache_dir, path)
        path =~ Regexp.new("^#{cache_dir}/dynamic_image[s]?")
      end
    end

    self.enabled ||= true
  end
end
