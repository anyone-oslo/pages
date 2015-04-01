# encoding: utf-8

require "find"
require "open-uri"

namespace :pages do
  namespace :update do
    desc "Update migrations"
    task migrations: :environment do
      removed_migrations = PagesCore::Plugin.remove_old_migrations!
      if removed_migrations.any?
        puts "\n#{removed_migrations.length} old migrations removed"
      end
    end
  end

  desc "Automated updates for newest version"
  task update: ["update:migrations"]
end
