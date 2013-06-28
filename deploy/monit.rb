# encoding: utf-8

namespace :monit do
  desc "Reconfigure Monit"
  desc "Start Monit"
  task :start do
    run "sudo /etc/init.d/monit start"
  end
  desc "Stop Monit"
  task :stop do
    run "sudo /etc/init.d/monit stop"
  end
  desc "Restart Monit"
  task :restart do
    run "sudo /etc/init.d/monit restart"
  end
  desc "Check Monit config syntax"
  task :syntax do
    run "sudo /etc/init.d/monit syntax"
  end
  desc "Show Monit status"
  task :status do
    run "sudo monit status"
  end
end
