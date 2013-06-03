# encoding: utf-8

require File.join(File.dirname(__FILE__), '../campfire.rb')

Capistrano::Configuration.instance(:must_exist).load do
  set :default_environment, {
    'PATH' => "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH"
  }

  set :remote_host, "server.manualdesign.no" unless variables.has_key?(:remote_host)
  set :remote_user, "rails" unless variables.has_key?(:remote_user)

  set :ssh_options, { :forward_agent => true }

  set :runner,      remote_user
  set :user,        remote_user
  set :use_sudo,    false
  set :deploy_to,   "/var/www/#{application}" unless variables.has_key?(:deploy_to) && deploy_to != "/u/apps/#{application}"
  set :web_server,  :apache2

  set :scm,                   "git"

  if variables.has_key?(:github) && github
    set :repository, "git@github.com:manualdesign/#{application}.git"
  else
    set :repository, "rails@manualdesign.no:~/git/sites/#{application}.git"
  end

  set :deploy_via,            :remote_cache
  set :git_enable_submodules, 1

  set :flush_cache,       true
  set :reindex_sphinx,    true
  set :cold_deploy,       false
  set :skip_services,     false
  set :use_monit,         true unless variables.keys.include?(:use_monit)

  set :monit_delayed_job, "#{application}_delayed_job"
  set :monit_sphinx,      "#{application}_sphinx"

  set :campfire_room, 555476 unless variables.has_key?(:campfire_room)

  role :web, remote_host
  role :app, remote_host
  role :db,  remote_host, :primary => true

  load File.join(File.dirname(__FILE__), '../../deploy/monit.rb')
  load File.join(File.dirname(__FILE__), '../../deploy/sphinx.rb')
  load File.join(File.dirname(__FILE__), '../../deploy/delayed_job.rb')
  load File.join(File.dirname(__FILE__), '../../deploy/pages.rb')

  desc "Run rake task (specified as TASK environment variable)"
  task :rake_task, :roles => :app do
    if ENV['TASK']
      run "cd #{deploy_to}/#{current_dir} && bundle exec rake #{ENV['TASK']} RAILS_ENV=production"
    else
      puts "Please specify a command to execute on the remote servers (via the COMMAND environment variable)"
    end
  end

  desc "Quick deploy, do not clean cache and reindex Sphinx"
  task :quick, :roles => [:web] do
    set :flush_cache,       false
    set :reindex_sphinx,    false
  end

  desc "Deploy without services"
  task :without_services, :roles => [:web] do
    set :skip_services, true
  end

  namespace :deploy do

    task :setup_cold_deploy, :roles => [:web] do
      set :cold_deploy, true
    end

    desc "Remove the cached copy"
    task :remove_cached_copy, :roles => [:web] do
      run "rm -rf #{deploy_to}/#{shared_dir}/cached-copy"
    end

    desc "Setup, configure the web server and deploy the application"
    task :cold, :roles => [:web] do
      run "echo \"Include #{current_path}/config/apache.conf\" > /etc/apache2/sites-available/#{application}"
      run "a2ensite #{application}"
    end

    desc "Create database"
    task :create_database, :roles => [:web] do
      run "cd #{release_path} && bundle exec rake db:create RAILS_ENV=production"
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

    desc "Ensure binary objects store"
    task :ensure_binary_objects, :roles => [:web] do
      run "mkdir -p #{deploy_to}/#{shared_dir}/binary-objects"
      run "ln -s #{deploy_to}/#{shared_dir}/binary-objects #{release_path}/db/binary-objects"
    end

    desc "Setup services"
    task :services, :roles => [:web] do
    end
    after 'deploy:services', 'sphinx:configure'
    after 'deploy:services', 'sphinx:index'
    after 'deploy:services', 'monit:configure'
    after 'deploy:services', 'monit:restart'

    desc "Precompile assets"
    task :precompile_assets do
      run "cd #{release_path}; RAILS_ENV=production bundle exec rake assets:precompile"
    end

    desc "Notify Campfire"
    task :notify_campfire, :roles => [:web] do
      if campfire_room
        username = `whoami`.chomp
        repo_name = repository.split('/').reverse[0..1].reverse.join('/').gsub(/\.git$/, '')
        begin
          room = Campfire.room(campfire_room)
          room.message "[#{repo_name}] has been deployed by #{username}"
        rescue Exception => e
          puts "Campfire notification failed: #{e.message}"
        end
      end
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
        run "cd #{deploy_to}/#{current_dir} && bundle exec rake pages:cache:sweep RAILS_ENV=production"
      end
    end
  end

  namespace :log do
    namespace :tail do
      desc "Tail production log"
      task :production, :roles => :app do
        run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
          puts  # for an extra line break before the host name
          puts "==== #{channel[:host]} ====\n#{data}"
          break if stream == :err
        end
      end

      desc "Tail delayed_job log"
      task :delayed_job, :roles => :app do
        run "tail -f #{shared_path}/log/delayed_job.log" do |channel, stream, data|
          puts  # for an extra line break before the host name
          puts "==== #{channel[:host]} ====\n#{data}"
          break if stream == :err
        end
      end
    end
  end

  # Setup
  after "deploy:setup",           "pages:create_shared_dirs"

  # Cold deploy
  before "deploy:cold",           "deploy:setup_cold_deploy"
  before "deploy:cold",           "without_services"
  before "deploy:cold",           "deploy:setup"
  after "deploy:cold",            "deploy"
  after "deploy:cold",            "deploy:create_database"
  after "deploy:cold",            "deploy:migrate"
  after "deploy:cold",            "deploy:services"
  after "deploy:cold",            "deploy:reload_webserver"

  # Symlinks
  after "deploy:finalize_update", "pages:symlinks"

  # Cache and assets
  after "deploy:restart",         "cache:flush"
  after "deploy:finalize_update", "deploy:ensure_binary_objects"
  after "deploy:finalize_update", "deploy:precompile_assets"

  # Sphinx
  after "deploy:finalize_update", "sphinx:configure"
  after "deploy:start",           "sphinx:start"
  after "deploy:stop",            "sphinx:start"
  after "deploy:restart",         "sphinx:restart"

  # Delayed Job
  after "deploy:start",           "delayed_job:start"
  after "deploy:stop",            "delayed_job:stop"
  after "deploy:restart",         "delayed_job:restart"

  # Campfire
  after "deploy:restart",         "deploy:notify_campfire"

end