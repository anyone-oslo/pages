# encoding: utf-8

require "bundler/capistrano"

set :application, "<%= @app_name %>"
set :remote_host, "chun-li.manualdesign.no"
set :github,      true
#set :deploy_to,   "/var/www/#{application}"

#load File.join(File.dirname(__FILE__), '../vendor/plugins/pages/deploy.rb')
require "pages_core/capistrano"

# Application specific tasks
namespace "#{application}".to_sym do
  desc "Create shared directories"
  task :setup, :roles => [:web,:app] do
    #run "mkdir -p #{deploy_to}/#{shared_dir}/some_dir"
  end

  desc "Create symlinks"
  task :create_symlink, :roles => [:web,:app] do
    #run "ln -s #{deploy_to}/#{shared_dir}/some_dir #{deploy_to}/#{current_dir}/public/some_dir"
  end
end

after "deploy:setup",   "#{application}:setup"
after "deploy:create_symlink", "#{application}:create_symlink"
