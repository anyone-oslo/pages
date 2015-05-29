add_source "http://gems.manualdesign.no/"

gem "pages_core", git: "git@github.com:manualdesign/pages.git", branch: "master"

gem_group :development do
  gem "manual_server", ">= 0.1.5"
end

route "root to: 'pages#index'"

run "echo '2.2.2' > .ruby-version"

run "bundle install"

generate "pages_core:install", "-f"
generate "pages_core:frontend", "-f"
generate "pages_core:rspec", "-f"
generate "manual_server", "-f"

rake "db:create"
rake "db:migrate"
