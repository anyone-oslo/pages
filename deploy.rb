set :remote_host, "server.manualdesign.no" unless variables[:remote_host]
set :remote_user, "rails" unless variables[:remote_user]

set :runner,      remote_user unless variables[:runner]
set :user,        remote_user unless variables[:user]
set :use_sudo,    false
set :deploy_to,   "/var/www/#{application}" unless variables[:deploy_to]
set :web_server,  :apache2 unless variables[:web_server]

set :repository,  "http://svn.manualdesign.no/svn/backstage/sites/#{application}/trunk"
set :scm, :subversion

set :flush_cache, true

role :web, remote_host
role :app, remote_host
role :db,  remote_host, :primary => true

namespace :deploy do

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
		run "cd #{deploy_to}/#{current_dir} && rake pages:update:fix_plugin_migrations"
	end
end

namespace :pages do

	desc "Create shared directories"
	task :create_shared_dirs, :roles => [:web,:app] do
		run "mkdir #{deploy_to}/#{shared_dir}/cache"
		run "mkdir #{deploy_to}/#{shared_dir}/public_cache"
		run "mkdir #{deploy_to}/#{shared_dir}/sockets"
		run "mkdir #{deploy_to}/#{shared_dir}/sessions"
		run "mkdir #{deploy_to}/#{shared_dir}/index"
		run "mkdir #{deploy_to}/#{shared_dir}/medieinformasjon" # FJ specific
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
		run "ln -s #{deploy_to}/#{shared_dir}/public_cache #{deploy_to}/#{current_dir}/public/cache"
	end
end

after "deploy:setup",    "pages:create_shared_dirs"
after "deploy:symlink",  "pages:fix_permissions"
after "deploy:symlink",  "pages:create_symlinks"
before "deploy:migrate", "deploy:fix_plugin_migrations"