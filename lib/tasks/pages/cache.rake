# encoding: utf-8

namespace :pages do
	namespace :cache do
		desc "Sweep the pages cache"
		task :sweep => :environment do
			swept_files = PagesCore::CacheSweeper.sweep!
			puts "Cache swept, #{swept_files.length} files deleted."
		end
		desc "Purge the entire pages cache"
		task :purge => :environment do
			PagesCore::CacheSweeper.purge!
			puts "Cache purged."
		end
	end
end