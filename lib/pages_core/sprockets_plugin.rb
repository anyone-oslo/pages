module PagesCore
  class SprocketsPlugin < Sprockets::Plugin
    root File.expand_path("../../..", __FILE__)
    append_path "app/assets/images"
    append_path "app/assets/javascripts"
    append_path "app/assets/stylesheets"
  end
end
