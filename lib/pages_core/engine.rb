# frozen_string_literal: true

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
        pages_core/admin.js
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
      ActionDispatch::ExceptionWrapper.rescue_responses.merge!(
        "PagesCore::NotAuthorized" => :forbidden
      )
    end

    initializer :healthcheck do |_app|
      Healthcheck.configure do |config|
        config.success = 200
        config.error = 503
        config.verbose = true
        config.route = "/healthcheck"
        config.method = :get

        # -- Checks --
        config.add_check :database, lambda {
          ActiveRecord::Base.connection.execute("select 1")
        }
        # config.add_check :migrations, lambda {
        #   ActiveRecord::Migration.check_pending!
        # }
        # config.add_check :cache, -> { Rails.cache.read("some_key") }
      end
    end

    initializer :lograge do |app|
      app.config.lograge.enabled = true if ENV["ENABLE_LOGRAGE"]
      app.config.lograge.formatter = Lograge::Formatters::Json.new
      app.config.lograge.ignore_actions =
        ["Healthcheck::HealthchecksController#check"]

      app.config.lograge.custom_options = lambda do |event|
        exclude_params = %w[controller action format id]
        { remote_ip: event.payload[:remote_ip],
          user_id: event.payload[:user_id],
          user_email: event.payload[:user_email],
          params: event.payload[:params]
                       .except(*exclude_params) }
      end
    end

    # React configuration
    initializer :react do |app|
      app.config.react.jsx_transform_options = {
        harmony: true
      }
    end
  end
end
