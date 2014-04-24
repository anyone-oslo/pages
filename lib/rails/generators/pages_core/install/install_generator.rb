# encoding: utf-8

module PagesCore
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Creates the Pages configuration"
      source_root File.expand_path("../templates", __FILE__)

      def get_configuration!
        default_app_name = Rails.root.to_s.split("/").last
        @app_name ||= ask("App name? [#{default_app_name}]")
        @app_name = default_app_name if @app_name.blank?
        @site_name ||= ask("Site name? [#{@app_name.humanize}]")
        @site_name = "#{@app_name.humanize}" if @site_name.blank?
        @domain_name ||= ask("Domain name? [#{@app_name}.no]")
        @domain_name = "#{@app_name}.no" if @domain_name.blank?
        @default_sender ||= ask("Default sender? [no-reply@#{@domain_name}]")
        @default_sender = "no-reply@#{@domain_name}" if @default_sender.blank?
        @sphinx_port ||= ask("Sphinx port? [3312]")
        @sphinx_port = "3312" if @sphinx_port.blank?
      end

      def add_gem_source
        add_source 'http://gems.manualdesign.no/'
      end

      def create_application_controller
        template 'application_controller.rb', File.join('app/controllers/application_controller.rb')
      end

      def create_application_helper
        template 'application_helper.rb', File.join('app/helpers/application_helper.rb')
      end

      def create_frontend_controller
        template 'frontend_controller.rb', File.join('app/controllers/frontend_controller.rb')
      end

      def create_frontend_helper
        template 'frontend_helper.rb', File.join('app/helpers/frontend_helper.rb')
      end

      def create_pages_controller
        template 'pages_controller.rb', File.join('app/controllers/pages_controller.rb')
      end

      def create_default_template
        copy_file 'default_page_template.html.erb', File.join('app/views/pages/templates/index.html.erb')
      end

      def create_delayed_job_script
        template 'delayed_job', File.join('script/delayed_job')
      end

      def create_delayed_job_initializer
        template 'delayed_job_initializer.rb', File.join('config/initializers/delayed_job.rb')
      end

      def create_dynamic_image_initializer
        template 'dynamic_image_initializer.rb', File.join('config/initializers/dynamic_image.rb')
      end

      def create_initializer_file
        get_configuration!
        template 'pages_initializer.rb', File.join('config/initializers/pages.rb')
      end

      def create_sphinx_config
        template 'thinking_sphinx.yml', File.join('config/thinking_sphinx.yml')
      end

      def create_gitignore
        template 'gitignore.erb', File.join('.gitignore')
      end
    end
  end
end