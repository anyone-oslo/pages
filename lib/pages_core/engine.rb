# encoding: utf-8

module PagesCore
  class Engine < Rails::Engine
    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    # Enable asset precompilation
    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w{pages/admin.js pages/admin.css pages/admin/print.css pages/errors.css}
    end
  end
end
