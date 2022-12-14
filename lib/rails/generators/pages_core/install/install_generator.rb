# frozen_string_literal: true

module PagesCore
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Creates the Pages configuration"
      source_root File.expand_path("templates", __dir__)

      def default_app_name
        Rails.root.to_s.split("/").last
      end

      def read_configuration!
        @app_name ||= ask_with_fallback("App name?", default_app_name)
        @site_name ||= ask_with_fallback("Site name?", @app_name.humanize)
        @domain_name ||= ask_with_fallback("Domain name?", "#{@app_name}.no")

        @default_sender ||= ask_with_fallback(
          "Default sender?",
          "no-reply@#{@domain_name}"
        )
        nil
      end

      def create_active_job_initializer
        template("active_job_initializer.rb",
                 File.join("config/initializers/active_job.rb"))
      end

      def create_application_controller
        template("application_controller.rb",
                 File.join("app/controllers/application_controller.rb"))
      end

      def create_application_helper
        template("application_helper.rb",
                 File.join("app/helpers/application_helper.rb"))
      end

      def create_frontend_controller
        template("frontend_controller.rb",
                 File.join("app/controllers/frontend_controller.rb"))
      end

      def create_frontend_helper
        template("frontend_helper.rb",
                 File.join("app/helpers/frontend_helper.rb"))
      end

      def create_pages_controller
        template("pages_controller.rb",
                 File.join("app/controllers/pages_controller.rb"))
      end

      def create_default_template
        copy_file("default_page_template.html.erb",
                  File.join("app/views/pages/templates/index.html.erb"))
      end

      def create_delayed_job_script
        template "delayed_job", File.join("bin/delayed_job")
        File.chmod(0o755, Rails.root.join("bin/delayed_job"))
      end

      def create_delayed_job_initializer
        template("delayed_job_initializer.rb",
                 File.join("config/initializers/delayed_job.rb"))
      end

      def create_initializer_file
        read_configuration!
        template("pages_initializer.rb",
                 File.join("config/initializers/pages.rb"))
      end

      def create_template_initializer
        read_configuration!
        template("page_templates_initializer.rb",
                 File.join("config/initializers/page_templates.rb"))
      end

      def create_gitignore
        template "gitignore.erb", File.join(".gitignore")
      end

      private

      def ask_with_fallback(question, default)
        result = ask(question + " [#{default}]")
        result.presence || default
      end
    end
  end
end
