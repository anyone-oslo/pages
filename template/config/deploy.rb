# encoding: utf-8

set :application, "<%= @app_name %>"
load File.join(File.dirname(__FILE__), '../vendor/plugins/pages/deploy.rb')

#set :deploy_to,   "/var/www/#{application}"

# Application specific tasks
namespace "#{application}".to_sym do
	desc "Create shared directories"
	task :setup, :roles => [:web,:app] do
		#run "mkdir -p #{deploy_to}/#{shared_dir}/some_dir"
	end

	desc "Create symlinks"
	task :symlink, :roles => [:web,:app] do
		#run "ln -s #{deploy_to}/#{shared_dir}/some_dir #{deploy_to}/#{current_dir}/public/some_dir"
	end
end

after "deploy:setup",   "#{application}:setup"
after "deploy:symlink", "#{application}:symlink"
