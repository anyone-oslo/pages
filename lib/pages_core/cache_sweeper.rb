# encoding: utf-8

module PagesCore
  class CacheSweeper
    class << self

      attr_accessor :enabled

      def disable(&block)
        old_value = self.enabled
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
          observe:    [Page, PageComment, Image],
          patterns:   [/^\/index\.[\w]+$/, /^\/pages\/[\w]{2,3}[\/\.](.*)$/, /^\/[\w]{2,3}\/(.*)$/]
        )
      end

      # Returns the configuration. Accepts a block, ie:
      #
      #   PagesCore::CacheSweeper.config do |c|
      #     c.observe  += [:store, :store_test]
      #     c.patterns += [/^\/arkiv(.*)$/, /^\/tests(.*)$/]
      #   end
      def config
        @@configuration ||= self.default_config
        if block_given?
          yield @@configuration
          extend_observed_models!
        end
        @@configuration
      end

      def extend_observed_models!
        config.observe.each do |klass|
          if klass.kind_of?(Symbol) || klass.kind_of?(String)
            klass = klass.to_s.camelize.constantize
          end
          unless klass.include?(PagesCore::Sweepable)
            klass.send(:include, PagesCore::Sweepable)
          end
        end
      end

      # Purge the entire pages cache
      def purge!
        cache_dir = self.config.cache_path
        if File.exist?(cache_dir)
          `rm -rf "#{cache_dir}/*"`
        end
      end

      # Sweep all cached pages
      def sweep!
        if self.enabled
          cache_base_dir = self.config.cache_path
          swept_files = []
          if PagesCore.config(:domain_based_cache)
            cache_dirs = Dir.entries(cache_base_dir)
            cache_dirs = cache_dirs.select{|d| !(d =~ /^\./) && File.directory?(File.join(cache_base_dir, d))}
            cache_dirs = cache_dirs.map{|d| File.join(cache_base_dir, d)}
          else
            cache_dirs = [cache_base_dir]
          end
          cache_dirs.each do |cache_dir|
            cache_dir = cache_dir.to_s
            if File.exist?(cache_dir)
              kill_patterns = self.config.patterns
              paths = []
              Find.find(cache_dir+"/") do |path|
                Find.prune if path =~ Regexp.new("^#{cache_dir}/dynamic_image[s]?") # Ignore dynamic image
                file = path.gsub(Regexp.new("^#{cache_dir}"), "")
                kill_patterns.each do |p|
                  if file =~ p && File.exist?( path )
                    swept_files << path
                    FileUtils.rm_rf(path)
                  end
                end
              end
            end
          end
          return swept_files
        else
          return []
        end
      end
    end
    self.enabled ||= true
  end
end
