# encoding: utf-8

require 'find'
require 'open-uri'

namespace :pages do
  namespace :update do
    desc "Update migrations"
    task :migrations => :environment do
      if removed_migrations = PagesCore::Plugin.remove_old_migrations!
        puts "\n#{removed_migrations.length} old migrations removed"
      end

      new_migrations = PagesCore::Plugin.mirror_migrations!
      if new_migrations.any?
        puts "\n#{new_migrations.length} new migrations added, now run rake db:migrate"
      end
    end
  end

  desc "Automated updates for newest version"
  task :update => ["update:migrations"]
end
