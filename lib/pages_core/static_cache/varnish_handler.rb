# frozen_string_literal: true

module PagesCore
  module StaticCache
    class VarnishHandler
      attr_reader :varnish_url

      def initialize(varnish_url)
        @varnish_url = varnish_url
      end

      def cache_page(controller, request, response)
        response.set_header("X-Cache-Tags", "static")
        request.session_options[:skip] = true
        controller.expires_in 1.hour, public: true
      end

      def cache_page_permanently(controller, request, response)
        response.set_header("X-Cache-Tags", "permanent")
        request.session_options[:skip] = true
        controller.expires_in 1.year, public: true
      end

      def purge!
        return unless PagesCore::CacheSweeper.enabled

        hydra = Typhoeus::Hydra.hydra
        hydra.queue(ban_request("static"))
        hydra.queue(ban_request("permanent"))
        hydra.run
      end

      def sweep!
        return unless PagesCore::CacheSweeper.enabled

        # PagesCore::SweepCacheJob.perform_later
        sweep_now!
      end

      def sweep_now!
        return unless PagesCore::CacheSweeper.enabled

        ban_request("static").run
      end

      private

      def ban_request(cache_tag)
        Typhoeus::Request.new(varnish_url,
                              method: :ban,
                              headers: { "X-Cache-Tags": cache_tag })
      end
    end
  end
end
