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

      # Returns the configuration. Accepts a block, ie:
      #
      #   PagesCore::CacheSweeper.config do |c|
      #     c.patterns += [/^\/arkiv(.*)$/, /^\/tests(.*)$/]
      #   end
      def config
        @configuration ||= default_config
        yield @configuration if block_given?
        @configuration
      end

      # Purge the entire pages cache
      def purge!
        cache_dir = config.cache_path
        FileUtils.rm_rf(Dir.glob("#{cache_dir}/*")) if File.exist?(cache_dir)
      end

      # Sweep all cached pages
      def sweep!
        return [] unless enabled
        cache_dirs.flat_map { |d| sweep_dir(d) }
      end

      private

      def cache_dirs
        if PagesCore.config(:domain_based_cache)
          Dir.entries(config.cache_path)
             .select { |d| visible_dir?(d) }
             .map { |d| File.join(config.cache_path, d).to_s }
        else
          [config.cache_path.to_s]
        end
      end

      # Returns the default configuration.
      def default_config
        OpenStruct.new(cache_path: ActionController::Base.page_cache_directory,
                       patterns: [%r{^/index\.[\w]+$},
                                  %r{^/sitemap\.[\w]+$},
                                  %r{^/pages/[\w]{2,3}[/\.](.*)$},
                                  %r{^/[\w]{2,3}/(.*)$}])
      end

      def visible_dir?(dir)
        dir !~ /^\./ && File.directory?(File.join(config.cache_path, dir))
      end

      def sweep_dir(cache_dir)
        PagesCore::CacheSweeper.new(cache_dir).sweep!
      end
    end

    attr_reader :cache_dir

    self.enabled ||= true

    def initialize(cache_dir)
      @cache_dir = cache_dir
    end

    def sweep!
      return [] unless File.exist?(cache_dir)
      swept_files = []

      Find.find(cache_dir + "/") do |path|
        Find.prune if skip_path?(path) || !File.exist?(path)

        if sweep_file?(path)
          swept_files << path
          FileUtils.rm_rf(path)
        end
      end
      swept_files
    end

    private

    def locales
      return [I18n.default_locale.to_s] unless PagesCore.config.locales

      ([I18n.default_locale.to_s] +
        PagesCore.config.locales.keys.map(&:to_s)).uniq
    end

    def page_path?(relative)
      return false unless relative =~ /\.html$/
      page_paths.each do |p|
        return true if relative.start_with?(p)
      end
      false
    end

    def page_paths
      @page_paths ||= PagePath.all.flat_map do |p|
        ["/#{p.path}"] + locales.map { |l| "/#{l}/#{p.path}" }
      end
    end

    def pattern_match?(path)
      PagesCore::CacheSweeper.config.patterns.select { |p| p =~ path }.any?
    end

    def skip_path?(path)
      path =~ Regexp.new("^#{cache_dir}/dynamic_image[s]?")
    end

    def sweep_file?(path)
      relative = path.gsub(Regexp.new("^#{cache_dir}"), "")
      pattern_match?(relative) || page_path?(relative)
    end
  end
end
