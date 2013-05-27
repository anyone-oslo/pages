# encoding: utf-8

module PagesCore
  class Engine < Rails::Engine
    # Enable asset precompilation
    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w{pages/admin.js pages/admin.css pages/admin/print.css pages/errors.css}
    end
  end
end
