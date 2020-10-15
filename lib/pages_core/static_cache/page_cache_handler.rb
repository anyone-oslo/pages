# frozen_string_literal: true

module PagesCore
  module StaticCache
    class PageCacheHandler
      def cache_page(controller, _request, _response)
        controller.cache_page
      end

      def cache_page_permanently(controller, _request, _response)
        controller.cache_page
      end

      def purge!
        Sweeper.purge!
      end

      def sweep!
        return unless PagesCore::CacheSweeper.enabled

        PagesCore::SweepCacheJob.perform_later
      end

      def sweep_now!
        Sweeper.sweep!
      end

      class << self
        # Returns the configuration. Accepts a block, ie:
        #
        #   PagesCore::StaticCache::PageCacheHandler.config do |c|
        #     c.patterns += [/^\/arkiv(.*)$/, /^\/tests(.*)$/]
        #   end
        def config
          @configuration ||= default_config
          yield @configuration if block_given?
          @configuration
        end

        private

        # Returns the default configuration.
        def default_config
          OpenStruct.new(patterns: [%r{^/index\.\w+$},
                                    %r{^/sitemap\.\w+$},
                                    %r{^/pages/\w{2,3}[/.](.*)$},
                                    %r{^/\w{2,3}/(.*)$}])
        end
      end

      class Sweeper
        class << self
          # Purge the entire pages cache
          def purge!
            return unless File.exist?(cache_path)

            FileUtils.rm_rf(Dir.glob("#{cache_path}/*"))
          end

          # Sweep all cached pages
          def sweep!
            return unless PagesCore::CacheSweeper.enabled

            new(cache_path.to_s).sweep!
          end

          private

          def cache_path
            ActionController::Base.page_cache_directory
          end
        end

        attr_reader :cache_dir

        def initialize(cache_dir)
          @cache_dir = cache_dir
        end

        def sweep!
          return [] unless File.exist?(cache_dir)

          swept_files = []

          Find.find("#{cache_dir}/") do |path|
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
          PagesCore::StaticCache::PageCacheHandler
            .config.patterns.select { |p| p =~ path }.any?
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
  end
end
