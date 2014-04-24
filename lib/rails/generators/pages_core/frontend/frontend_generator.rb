# encoding: utf-8

module PagesCore
  module Generators
    class FrontendGenerator < Rails::Generators::Base
      desc "Creates the default Pages frontend"
      source_root File.expand_path("../templates", __FILE__)

      def install_gems
        gem 'modernizr-rails'
        gem 'selectivizr-rails'
      end

      def create_layout
        template 'layout.html.erb', File.join('app/views/layouts/application.html.erb')
      end

      def create_application_css
        template 'application.css.erb', File.join('app/assets/stylesheets/application.css')
      end

      def create_normalize_css
        template 'normalize.css.erb', File.join('app/assets/stylesheets/normalize.css')
      end

      def create_mixins_css
        template 'mixins.css.scss.erb', File.join('app/assets/stylesheets/mixins.css.scss')
      end

      def create_base_css
        template 'base.css.scss.erb', File.join('app/assets/stylesheets/components/base.css.scss')
      end

      def create_application_js
        template 'application.js.erb', File.join('app/assets/javascripts/application.js')
      end
    end
  end
end