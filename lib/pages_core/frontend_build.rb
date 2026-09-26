# frozen_string_literal: true

module PagesCore
  module FrontendBuild
    class MissingBuildError < StandardError; end

    class << self
      def path(asset)
        PagesCore.plugin_root.join("app/assets/builds", asset)
      end

      def require!(asset)
        return if path(asset).exist?

        raise MissingBuildError, missing_message(asset)
      end

      private

      def missing_message(asset)
        "Pages' frontend assets have not been built " \
          "(#{path(asset)} is missing). Run `pnpm install && pnpm build && " \
          "pnpm build:css` in #{PagesCore.plugin_root}."
      end
    end
  end
end
