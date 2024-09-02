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
        ["application.postcss.css",
         "config.css",
         "components/base.css",
         "components/layout.css",
         "global/animation.css",
         "global/colors.css",
         "global/fonts.css",
         "global/grid.css",
         "global/typography.css"].each do |f|
          template("stylesheets/#{f}", File.join("app/assets/stylesheets/#{f}"))
        end
      end

      def create_js_framework
        ["lib/responsiveEmbeds.ts",
         "lib/gridOverlay.ts"].each do |f|
          template("javascript/#{f}", File.join("app/javascript/#{f}"))
        end

        append_to_file "app/javascript/application.js" do
          <<~JS
            // Responsive embeds
            import responsiveEmbeds from "./lib/responsiveEmbeds";
            responsiveEmbeds();

            // Grid overlay
            import gridOverlay from "./lib/gridOverlay";
            gridOverlay();
          JS
        end
      end

      def install_js_dependencies
        run("yarn add autoprefixer cssnano normalize.css postcss " \
            "postcss-calc postcss-cli postcss-import " \
            "postcss-import-ext-glob postcss-mixins postcss-preset-env " \
            "postcss-image-inliner")
      end

      def configure_postcss
        copy_file("postcss.config.js",
                  File.join("postcss.config.js"))
      end

      def configure_build_script
        script = "postcss ./app/assets/stylesheets/application.postcss.css " \
                 "-o ./app/assets/builds/application.css"
        run %(npm set-script build:css "#{script}")
      end

      def remove_application_css
        remove_file("app/assets/stylesheets/application.css")
      end
    end
  end
end
