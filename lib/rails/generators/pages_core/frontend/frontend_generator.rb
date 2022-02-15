# frozen_string_literal: true

module PagesCore
  module Generators
    class FrontendGenerator < Rails::Generators::Base
      desc "Creates the default Pages frontend"
      source_root File.expand_path("templates", __dir__)

      def create_layout
        copy_file(
          "application.html.erb",
          File.join("app/views/layouts/application.html.erb")
        )
      end

      def create_css_framework
        ["application.sass.scss",
         "config.scss",
         "components/base.scss",
         "framework/breakpoints.scss",
         "framework/clearfix.scss",
         "framework/grid.scss",
         "framework/grid_overlay.scss",
         "global/colors.scss",
         "global/typography.scss",
         "vendor/normalize.css"].each do |f|
          template("stylesheets/#{f}", File.join("app/assets/stylesheets/#{f}"))
        end
      end

      def create_js_framework
        ["lib/ResponsiveEmbeds.js",
         "lib/GridOverlay.js"].each do |f|
          template("javascript/#{f}", File.join("app/javascript/#{f}"))
        end

        append_to_file "app/javascript/application.js" do
          <<~JS
            // Responsive embeds
            import ResponsiveEmbeds from "./frontend/ResponsiveEmbeds";
            ResponsiveEmbeds.start();

            // Grid overlay
            import GridOverlay from "./frontend/GridOverlay";
            GridOverlay.start();
          JS
        end
      end

      def remove_application_css
        remove_file("app/assets/stylesheets/application.css")
      end
    end
  end
end
