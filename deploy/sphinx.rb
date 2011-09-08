namespace :sphinx do
	desc "Rebuild Sphinx"
	task :rebuild do
		run "cd #{deploy_to}/#{current_dir} && rake ts:in RAILS_ENV=production"
		run "sudo monit restart #{monit_sphinx}"
	end
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
		if use_monit
			run "sudo monit start #{monit_sphinx}"
		else
			run "cd #{deploy_to}/#{current_dir} && rake ts:start RAILS_ENV=production"
		end
	end
	desc "Stop Sphinx"
	task :stop do
		unless cold_deploy
			if use_monit
				run "sudo monit stop #{monit_sphinx}"
			else
				run "cd #{deploy_to}/#{current_dir} && rake ts:stop RAILS_ENV=production"
			end
		end
	end
	desc "Restart Sphinx"
	task :restart do
		if use_monit
			run "sudo monit restart #{monit_sphinx}"
		else
			run "cd #{deploy_to}/#{current_dir} && rake ts:restart RAILS_ENV=production"
		end
	end
	desc "Do not reindex Sphinx"
	task :skip_reindex do
		set :reindex_sphinx, false
	end
end

