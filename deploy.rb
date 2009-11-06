set :remote_host, "server.manualdesign.no"
set :remote_user, "rails"

set :runner,      remote_user
set :user,        remote_user
set :use_sudo,    false
set :deploy_to,   "/var/www/#{application}"
set :web_server,  :apache2

set :scm,                   "git"
set :repository,            "rails@manualdesign.no:~/git/sites/#{application}.git"
set :deploy_via,            :remote_cache
set :git_enable_submodules, 1

set :flush_cache, true

role :web, remote_host
role :app, remote_host
role :db,  remote_host, :primary => true

namespace :deploy do

	desc "Setup, configure the web server and deploy the application"
	task :cold, :roles => [:web] do
		sudo "echo \"Include #{current_path}/config/apache.conf\" > /etc/apache2/sites-available/#{application}"
		sudo "a2ensite #{application}"
		run "cd #{deploy_to}/#{current_dir} && rake db:create RAILS_ENV=production"
	end

	desc "Restart application"
	task :restart, :roles => :app do
		run "touch #{current_path}/tmp/restart.txt"
	end

	desc "Reload webserver"
	task :reload_webserver, :roles => [:web] do
	    sudo "/etc/init.d/#{web_server} reload"
	end

	desc "Update plugin migrations"
	task :fix_plugin_migrations, :roles => [:db] do
		run "cd #{release_path} && rake pages:update:fix_plugin_migrations RAILS_ENV=production --trace"
	end
end

namespace :pages do

	desc "Verify migrations"
	task :verify_migrations, :roles => [:web, :app, :db] do
		migration_status = `rake -s pages:migration_status`
		current, plugin = (migration_status.split("\n").select{|l| l =~ /pages:/ }.first.match(/([\d]+\/[\d]+)/)[1] rescue "0/xx").split("/")
		unless current == plugin
			puts "================================================================================"
			puts "MIGRATIONS MISMATCH!"
			puts migration_status
			puts "\nRun the following commands to fix:"
			puts "\nrake pages:update\nrake db:migrate\nsvn ci -m \"#{application}: Fixed migrations\"\ncap deploy:migrations"
			puts
			exit
		end
	end

	desc "Create shared directories"
	task :create_shared_dirs, :roles => [:web,:app] do
		run "mkdir -p #{deploy_to}/#{shared_dir}/cache"
		run "mkdir -p #{deploy_to}/#{shared_dir}/public_cache"
		run "mkdir -p #{deploy_to}/#{shared_dir}/sockets"
		run "mkdir -p #{deploy_to}/#{shared_dir}/sessions"
		run "mkdir -p #{deploy_to}/#{shared_dir}/index"
		run "mkdir -p #{deploy_to}/#{shared_dir}/sphinx"
	end

	desc "Fix permissions"
	task :fix_permissions, :roles => [:web, :app] do
		run "chmod -R a+x #{deploy_to}/#{current_dir}/script/*"
		run "chmod a+x    #{deploy_to}/#{current_dir}/public/dispatch.*"
		run "chmod a+rwx  #{deploy_to}/#{current_dir}/public"
		run "chmod a+rw   #{deploy_to}/#{current_dir}/public/plugin_assets"
	end

	desc "Create symlinks"
	task :create_symlinks, :roles => [:web,:app] do
		run "ln -s #{deploy_to}/#{shared_dir}/cache #{deploy_to}/#{current_dir}/tmp/cache"
		run "ln -s #{deploy_to}/#{shared_dir}/sockets #{deploy_to}/#{current_dir}/tmp/sockets"
		run "ln -s #{deploy_to}/#{shared_dir}/sessions #{deploy_to}/#{current_dir}/tmp/sessions"
		run "ln -s #{deploy_to}/#{shared_dir}/index #{deploy_to}/#{current_dir}/index"
		run "ln -s #{deploy_to}/#{shared_dir}/sphinx #{deploy_to}/#{current_dir}/db/sphinx"
		run "ln -s #{deploy_to}/#{shared_dir}/public_cache #{deploy_to}/#{current_dir}/public/cache"
	end

end

namespace :sphinx do
	desc "Configure Sphinx"
	task :configure do
        run "cd #{deploy_to}/#{current_dir} && rake ts:conf RAILS_ENV=production"
	end
	desc "(Re)index Sphinx"
	task :index do
        run "cd #{deploy_to}/#{current_dir} && rake ts:in RAILS_ENV=production"
	end
	desc "Start Sphinx"
	task :start do
        run "cd #{deploy_to}/#{current_dir} && rake ts:start RAILS_ENV=production"
	end
	desc "Stop Sphinx"
	task :stop do
        run "cd #{deploy_to}/#{current_dir} && rake ts:stop RAILS_ENV=production"
	end
	desc "Restart Sphinx"
	task :restart do
        run "cd #{deploy_to}/#{current_dir} && rake ts:restart RAILS_ENV=production"
	end
end

namespace :cache do
	desc "Do not flush the page cache on reload"
	task :keep do
	    set :flush_cache, false
	end

	desc "Flush the page cache"
	task :flush, :roles => :app do
	    if flush_cache
	        run "cd #{deploy_to}/#{current_dir} && rake pages:cache:sweep RAILS_ENV=production"
	    end
	end
end

before "deploy", "pages:verify_migrations"

after "deploy:setup",    "pages:create_shared_dirs"
after "deploy:symlink",  "pages:fix_permissions"
after "deploy:symlink",  "pages:create_symlinks"
#after "deploy:restart",  "sphinx:index"
after "deploy:restart",  "cache:flush"
before "deploy:migrate", "deploy:fix_plugin_migrations"

before "deploy:cold", "deploy:setup"
before "deploy:cold", "deploy"
after "deploy:cold", "deploy:reload_webserver"
after "deploy:cold", "sphinx:start"