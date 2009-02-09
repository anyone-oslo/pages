namespace :pages do
	namespace :cache do
		desc "Sweep the pages cache"
		task :sweep => :environment do
			if Object.const_defined?("CacheSweeper")
				swept_files = CacheSweeper.sweep!
				puts "Cache swept, #{swept_files.length} files deleted."
			end
		end
	end
end