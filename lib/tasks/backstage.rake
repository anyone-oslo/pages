namespace :backstage do
	
	desc "Patch routes for Rails 2.0"
	task :patch_routes => :environment do
		require 'routepatcher'
		dir = File.join(File.dirname(__FILE__),'..','..','..','..','..')
		patcher = RoutePatcher.new( dir )
		patcher.register_prefix( [ 'admin', 'backstage' ] )
		patcher.patch!
	end

	desc "Deliver mailing queue"
	task :deliver_mailings => :environment do
		puts "Delivering mailings"
		Mailing.do_queue
	end
	
	desc "Remove stale sessions"
	task :clean_sessions => :environment do
		puts "Removing stale sessions"
		SessionCleaner.remove_stale_sessions
	end
	
	desc "Refresh RSS feeds"
	task :refresh_feeds => :environment do
		puts "Refreshing external feeds"
		Feed.refresh_feeds
	end
	
	desc "Perform routine maintenance"
	task :maintenance => [ :clean_sessions, :refresh_feeds, :deliver_mailings ] do
	end
	
	desc "Pack application for transporting (clear unnecessary files, dump schema)"
	task :pack => :environment do
		Rake::Task["log:clear"].invoke
		Rake::Task["tmp:clear"].invoke
		Rake::Task["doc:clobber_app"].invoke
		Rake::Task["doc:clobber_rails"].invoke
		Rake::Task["doc:clobber_plugins"].invoke
		Rake::Task["db:schema:dump"].invoke
	end
	
	desc "Unpack application (generate documentation)"
	task :unpack => :environment do
		Rake::Task["doc:app"].invoke
		Rake::Task["doc:plugins"].invoke
	end
	
	desc "Migration status"
	task :migration_status => :environment do
		
		puts "Plugins:"
		plugins = Rails.plugins.select{ |p| p.latest_migration }
		longest_name = plugins.mapped.name.sort{|a,b| a.length <=> b.length }.last.length + 1
		plugins.each do |p|
			puts "  " + "#{p.name}:".ljust(longest_name,' ')+" "+Engines::Plugin::Migrator.current_version( p ).to_s+"/#{p.latest_migration}"
		end
	end
	
	desc "Automated updates for newest version"
	task :update => :environment do
		# Update plugins
		plugins = Rails.plugins.select{|p| p.latest_migration}
		plugins_migrated = 0
		plugins.each do |plugin|
			if plugin.name =~ /^backstage/ && plugin.latest_migration != Engines::Plugin::Migrator.current_version(plugin)
				puts "Generating migrations for plugin #{plugin.name}..."
				`script/generate plugin_migration #{plugin.name}`
				plugins_migrated += 1
			end
		end
		if plugins_migrated > 0
			`svn -q add db/migrate/*`
			puts "\nNew migrations added, now run rake db:migrate"
		end
	end
	
end

