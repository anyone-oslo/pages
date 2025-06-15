# frozen_string_literal: true

module PagesCore
  class Engine < Rails::Engine
    initializer "pages_core.factory_bot" do |app|
      path = File.expand_path("../../spec/factories", __dir__)

      if defined?(FactoryBotRails)
        app.config.factory_bot.definition_file_paths << path
        FactoryBot.definition_file_paths =
          Rails.application.config.factory_bot.definition_file_paths
      end
    end

    initializer "pages_core.migrations" do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    initializer "pages_core.sprockets" do |app|
      next unless Object.const_defined?("Sprockets::Railtie")

      app.config.assets.precompile += %w[
        pages_core/admin-dist.js
        pages_core/admin.css
        pages_core/mailer.css
        pages_core/fonts/*.ttf
        pages_core/fonts/*.woff2
        pages/favicon.gif
        pages/admin/icon.svg
        pages/*.gif
        pages/*.png
        pages/*.jpg
      ]
    end

    initializer "pages_core.rescue_response" do |app|
      app.config.exceptions_app = app.routes
      ActionDispatch::ExceptionWrapper.rescue_responses.merge!(
        "PagesCore::NotAuthorized" => :forbidden
      )
    end

    initializer "pages_core.deprecator" do |app|
      app.deprecators[:pages_core] = PagesCore.deprecator
    end

    initializer "pages_core.sitemap" do |_app|
      PagesCore::Sitemap.register { |loc| pages_sitemap_url(loc, format: :xml) }
    end
  end
end
