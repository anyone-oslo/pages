namespace :pages do
	namespace :cache do
		desc "Sweep the pages cache"
		task :sweep => :environment do
			swept_files = PagesCore::CacheSweeper.sweep!
			puts "Cache swept, #{swept_files.length} files deleted."
		end
	end
end