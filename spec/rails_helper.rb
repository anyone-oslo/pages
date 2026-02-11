# frozen_string_literal: true

require "simplecov"
SimpleCov.start

ENV["RAILS_ENV"] ||= "test"
ENV["DB"] ||= "postgres"

require File.expand_path("internal/config/environment", __dir__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rails-controller-testing"
require "spec_helper"
require "rspec/rails"
require "factory_bot"
require "shoulda-matchers"
require "timecop"

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Rails.root.glob("../support/**/*.rb").each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
# ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.backtrace_exclusion_patterns = [
    %r{/lib\d*/ruby/},
    %r{bin/},
    %r{spec/spec_helper\.rb},
    %r{lib/rspec/(core|expectations|matchers|mocks)}
  ]

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # Use FactoryBot shorthand
  config.include FactoryBot::Syntax::Methods

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs

  config.infer_spec_type_from_file_location!

  # config.include JsonSpec::Helpers
  config.include ActiveJob::TestHelper
  config.include ErrorResponses
  config.include SystemHelpers, type: :system
  config.include LoginMacros
  config.include MailerMacros

  config.before do
    PagesCore.reset_configuration!
    reset_email
  end

  config.around(realistic_error_responses: true) do |example|
    respond_without_detailed_exceptions(&example)
  end

  config.after do
    # Clean the Dis storage after each example
    storage_root = Rails.root.join("db/dis/test")
    FileUtils.rm_rf(storage_root)

    # Reset the ActiveJob queue
    ActiveJob::Base.queue_adapter.enqueued_jobs = []
    ActiveJob::Base.queue_adapter.performed_jobs = []
  end

  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, :js) do
    driven_by :selenium_chrome_headless
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

FactoryBot.find_definitions
