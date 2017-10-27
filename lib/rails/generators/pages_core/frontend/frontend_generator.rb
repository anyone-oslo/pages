module PagesCore
  module Generators
    class FrontendGenerator < Rails::Generators::Base
      desc "Creates the default Pages frontend"
      source_root File.expand_path("../templates", __FILE__)

      def create_layout
        copy_file(
          "layout.html.erb",
          File.join("app/views/layouts/application.html.erb")
        )
      end

      def create_application_scss
        template(
          "application.scss.erb",
          File.join("app/assets/stylesheets/application.scss")
        )
      end

      def remove_application_css
        remove_file("app/assets/stylesheets/application.css")
      end

      def create_normalize_css
        template(
          "normalize.css.erb",
          File.join("vendor/assets/stylesheets/normalize.css")
        )
      end

      def create_breakpoints_css
        template(
          "breakpoints.scss.erb",
          File.join("app/assets/stylesheets/mixins/breakpoints.scss")
        )
      end

      def create_clearfix_css
        template(
          "clearfix.scss.erb",
          File.join("app/assets/stylesheets/mixins/clearfix.scss")
        )
      end

      def create_base_css
        template(
          "base.scss.erb",
          File.join("app/assets/stylesheets/components/base.scss")
        )
      end

      def create_application_js
        template(
          "application.js.erb",
          File.join("app/assets/javascripts/application.js")
        )
      end
    end
  end
end
