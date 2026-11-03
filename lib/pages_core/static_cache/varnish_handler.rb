# frozen_string_literal: true

require "typhoeus"

module PagesCore
  module StaticCache
    class VarnishHandler
      attr_reader :varnish_url

      def initialize(varnish_url)
        @varnish_url = varnish_url
      end

      def cache_page(_controller, request, response)
        response.set_header("X-Cache-Tags", "static")
        request.session_options[:skip] = true
        # controller.expires_in 1.hour, public: true
      end

      def cache_page_permanently(controller, request, response, tags: [])
        tag_permanently(response, tags)
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

      def purge_record!(record)
        return unless PagesCore::CacheSweeper.enabled

        ban_request(
          "(^|[[:space:]])#{record.cache_tag}([[:space:]]|$)"
        ).run
      end

      def tag_permanently(response, tags)
        response.set_header("X-Cache-Tags", ["permanent", *tags].join(" "))
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
