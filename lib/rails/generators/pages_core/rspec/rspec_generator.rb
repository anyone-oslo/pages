module PagesCore
  module Generators
    class RspecGenerator < Rails::Generators::Base
      desc "RSpec setup"
      source_root File.expand_path("templates", __dir__)

      def setup_development_gems
        gem_group :development do
          gem "spring-commands-rspec"
        end
      end

      def setup_test_gems
        gem_group :test, :development do
          gem "rspec-rails"
          gem "shoulda-matchers", require: false
          gem "json_spec"
          gem "capybara"
          gem "timecop"
          gem "factory_bot_rails"
        end
      end

      def setup_rspec
        create_file File.join(".rspec"), "--colour"
        create_file File.join("spec/controllers/.keep")
        create_file File.join("spec/factories/.keep")
        create_file File.join("spec/models/.keep")
        template "spec_helper.rb", File.join("spec/spec_helper.rb")
        template "factories.rb", File.join("spec/support/factories.rb")
        template "mailer_macros.rb", File.join("spec/support/mailer_macros.rb")
      end
    end
  end
end
