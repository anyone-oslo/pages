module PagesCore
  class Engine < Rails::Engine
    # config.autoload_paths += Dir["#{config.root}/lib/"]
    # config.autoload_paths += Dir["#{config.root}/lib/pages_core/**/"]
    # config.eager_load_paths += Dir["#{config.root}/lib/pages_core/**/"]

    initializer :factory_bot_definitions do |app|
      path = File.expand_path("../../spec/factories", __dir__)

      if defined?(FactoryBotRails)
        app.config.factory_bot.definition_file_paths << path
        FactoryBot.definition_file_paths =
          Rails.application.config.factory_bot.definition_file_paths
      end
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    # Enable asset precompilation
    initializer :assets do |_config|
      Rails.application.config.assets.precompile += %w[
        pages/admin.js
        pages/admin.css
        pages/errors.css
        pages/favicon.gif
        pages/admin/icon.png
        pages/*.gif
        pages/*.png
        pages/*.jpg
      ]
    end

    initializer :enable_recursive_serialization do |_app|
      ActiveModelSerializers.config.default_includes = "**"
    end

    initializer :handle_exceptions do |app|
      app.config.exceptions_app = app.routes
    end

    # React configuration
    initializer :react do |app|
      app.config.react.jsx_transform_options = {
        harmony: true
      }
    end
  end
end
