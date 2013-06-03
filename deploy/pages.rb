# encoding: utf-8

namespace :pages do

  desc "Create shared directories"
  task :create_shared_dirs, :roles => [:web,:app] do
    run "mkdir -p #{deploy_to}/#{shared_dir}/cache"
    run "mkdir -p #{deploy_to}/#{shared_dir}/public_cache"
    run "mkdir -p #{deploy_to}/#{shared_dir}/sockets"
    run "mkdir -p #{deploy_to}/#{shared_dir}/sessions"
    run "mkdir -p #{deploy_to}/#{shared_dir}/index"
    run "mkdir -p #{deploy_to}/#{shared_dir}/sphinx"
    run "mkdir -p #{deploy_to}/#{shared_dir}/binary-objects"
  end

  desc "Create symlinks"
  task :symlinks, :roles => [:web,:app] do
    run "ln -s #{deploy_to}/#{shared_dir}/cache #{release_path}/tmp/cache"
    run "ln -s #{deploy_to}/#{shared_dir}/sockets #{release_path}/tmp/sockets"
    run "ln -s #{deploy_to}/#{shared_dir}/sessions #{release_path}/tmp/sessions"
    run "ln -s #{deploy_to}/#{shared_dir}/index #{release_path}/index"
    run "ln -s #{deploy_to}/#{shared_dir}/sphinx #{release_path}/db/sphinx"
    run "ln -s #{deploy_to}/#{shared_dir}/public_cache #{release_path}/public/cache"
  end

end
