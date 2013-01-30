# encoding: utf-8

namespace :delayed_job do
  desc "Start delayed_job process"
  task :start, :roles => :app do
    unless skip_services
      if use_monit
        run "sudo monit start #{monit_delayed_job}"
      else
        run "cd #{deploy_to}/#{current_dir} && script/delayed_job start production"
      end
    end
  end

  desc "Stop delayed_job process"
  task :stop, :roles => :app do
    unless cold_deploy || skip_services
      if use_monit
        run "sudo monit stop #{monit_delayed_job}"
      else
        run "cd #{deploy_to}/#{current_dir} && script/delayed_job stop production"
      end
    end
  end

  desc "Restart delayed_job process"
  task :restart, :roles => :app do
    unless skip_services
      if use_monit
        run "sudo monit restart #{monit_delayed_job}"
      else
        run "cd #{deploy_to}/#{current_dir} && script/delayed_job restart production"
      end
    end
  end
end
