namespace :sphinx do
	desc "Rebuild Sphinx"
	task :rebuild do
		unless skip_services
			run "cd #{deploy_to}/#{current_dir} && bundle exec rake ts:in RAILS_ENV=production"
			run "sudo monit restart #{monit_sphinx}"
		end
	end
	desc "Configure Sphinx"
	task :configure do
		unless skip_services
			run "cd #{release_path} && bundle exec rake ts:conf RAILS_ENV=production"
		end
	end
	desc "(Re)index Sphinx"
	task :index do
		unless skip_services
			run "cd #{deploy_to}/#{current_dir} && bundle exec rake ts:in RAILS_ENV=production"
		end
	end
	desc "Start Sphinx"
	task :start do
		unless skip_services
			if use_monit
				run "sudo monit start #{monit_sphinx}"
			else
				run "cd #{deploy_to}/#{current_dir} && bundle exec rake ts:start RAILS_ENV=production"
			end
		end
	end
	desc "Stop Sphinx"
	task :stop do
		unless cold_deploy || skip_services
			if use_monit
				run "sudo monit stop #{monit_sphinx}"
			else
				run "cd #{deploy_to}/#{current_dir} && bundle exec rake ts:stop RAILS_ENV=production"
			end
		end
	end
	desc "Restart Sphinx"
	task :restart do
		unless cold_deploy || skip_services
			if use_monit
				run "sudo monit restart #{monit_sphinx}"
			else
				run "cd #{deploy_to}/#{current_dir} && bundle exec rake ts:restart RAILS_ENV=production"
			end
		end
	end
	desc "Do not reindex Sphinx"
	task :skip_reindex do
		set :reindex_sphinx, false
	end
end

