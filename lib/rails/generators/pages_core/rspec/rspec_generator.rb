# frozen_string_literal: true

module PagesCore
  module Generators
    class RspecGenerator < Rails::Generators::Base
      desc "RSpec setup"
      source_root File.expand_path("templates", __dir__)

      def setup_test_gems
        gem_group :development, :test do
          gem "capybara"
          gem "factory_bot_rails"
          gem "fuubar"
          gem "json_spec"
          gem "rspec-rails"
          gem "rspec_junit_formatter"
          gem "selenium-webdriver"
          gem "shoulda-matchers", require: false
          gem "simplecov", require: false
        end
      end

      def setup_rspec
        create_file File.join(".rspec"), "--format Fuubar\n--colour\n" \
                                         "--require spec_helper"
        create_file File.join("spec/controllers/.keep")
        create_file File.join("spec/mailers/preview/.keep")
        create_file File.join("spec/models/.keep")
        create_file File.join("spec/system/.keep")
        template "spec_helper.rb", File.join("spec/spec_helper.rb")
        template "rails_helper.rb", File.join("spec/rails_helper.rb")
        template "factories.rb", File.join("spec/factories.rb")
        template "mailer_macros.rb", File.join("spec/support/mailer_macros.rb")
        template("page_templates_spec.rb",
                 File.join("spec/system/page_templates_spec.rb"))
      end
    end
  end
end
