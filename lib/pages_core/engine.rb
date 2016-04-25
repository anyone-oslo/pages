# encoding: utf-8

module PagesCore
  class Engine < Rails::Engine
    config.autoload_paths += Dir["#{config.root}/lib/"]
    config.autoload_paths += Dir["#{config.root}/lib/pages_core/**/"]
    config.eager_load_paths += Dir["#{config.root}/lib/pages_core/**/"]

    initializer :active_job do |_config|
      ActiveJob::Base.queue_adapter = if Rails.env.test?
                                        :test
                                      else
                                        :delayed_job
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
      Rails.application.config.assets.precompile += %w(
        pages/admin.js
        pages/admin.css
        pages/admin/print.css
        pages/errors.css
        pages/*.gif
        pages/*.png
        pages/*.jpg
      )
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
