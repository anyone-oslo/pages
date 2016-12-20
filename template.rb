gem "pages_core", git: "git@github.com:kord-as/pages.git", branch: "master"

gem_group :development do
  gem "manual_server", git: "git@github.com:kord-as/manual_server.git"
end

route "root to: 'pages#index'"

run "echo '2.3.1' > .ruby-version"

run "bundle install"

generate "pages_core:install", "-f"
generate "pages_core:frontend", "-f"
generate "pages_core:rspec", "-f"
generate "manual_server", "-f"

rake "db:create"
rake "db:migrate"
