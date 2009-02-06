namespace :pages do
	namespace :cache do
		desc "Sweep the pages cache"
		task :sweep => :environment do
			if Object.const_defined?("CacheSweeper")
				CacheSweeper.sweep!
			end
		end
	end
end