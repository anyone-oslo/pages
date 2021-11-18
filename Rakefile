# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

APP_RAKEFILE = "spec/internal/Rakefile"
load "rails/tasks/engine.rake"

RSpec::Core::RakeTask.new

def current_version
  Semantic::Version.new(PagesCore::VERSION)
end

def write_version(version)
  puts "Updating version to #{version}..."
  File.open(File.expand_path("./VERSION", __dir__), "w") do |fh|
    fh.write(version.to_s)
  end
  `npm version #{version} --git-tag-version=false`
  `bundle`
end

desc "Increment to next patch version"
task "version:patch" => :environment do
  write_version(current_version.patch!)
end

desc "Increment to next minor version"
task "version:minor" => :environment do
  write_version(current_version.minor!)
end

desc "Increment to next major version"
task "version:major" => :environment do
  write_version(current_version.major!)
end

desc "Push NPM package"
task "release:npm" => :environment do
  system("npm publish --access public")
end

Rake::Task["release"].enhance do
  Rake::Task["release:npm"].invoke
end

task default: :spec
task test: :spec
