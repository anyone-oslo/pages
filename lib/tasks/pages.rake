namespace :pages do
	
	desc "Patch routes for Rails 2.0"
	task :patch_routes => :environment do
		require 'routepatcher'
		dir = File.join(File.dirname(__FILE__),'..','..','..','..','..')
		patcher = RoutePatcher.new( dir )
		patcher.register_prefix( [ 'admin', 'pages' ] )
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
	
	namespace :update do
		desc "Patch files"
		task :files do
			require 'find'
			def patch_files(file_expression, expression, sub)
				updated_files = []
				Find.find(".") do |path|
					if path.gsub(/^\.?\/?/,'') =~ file_expression
						file_content = File.read(path)
						patched_file_content = file_content.gsub(expression, sub)
						unless file_content == patched_file_content
							puts "Patching file #{path}.."
							updated_files << path
							File.open(path, 'w') {|fh| fh.write(patched_file_content)}
						end
					end
				end
				if updated_files.length > 0
					yield updated_files if block_given?
				end
			end
			patch_files %r%^config/environment.rb% , /^[\s]*RAILS_GEM_VERSION[\s]*=[\s]*'([\d\.]*)'/, "RAILS_GEM_VERSION = '2.2.2'" do
				abort "\nRails gem version updated to newest, stopping. Please run rake rails:update, then re-run this task to complete."
			end
		end

		desc "Fix plugin migrations"
		task :fix_plugin_migrations => :environment do
			if ActiveRecord::Base.connection.table_exists?("plugin_schema_info")
				puts "Pre-2.2.2 plugin migrations table detected, upgrading..."
				ActiveRecord::Base.connection.update("UPDATE plugin_schema_info SET plugin_name = \"pages\" WHERE plugin_name = \"backstage\"")
				ActiveRecord::Base.connection.update("UPDATE plugin_schema_info SET plugin_name = \"pages_gallery\" WHERE plugin_name = \"backstage_gallery\"")
				ActiveRecord::Base.connection.update("UPDATE plugin_schema_info SET plugin_name = \"pages_portfolio\" WHERE plugin_name = \"backstage_portfolio\"")
				Rake::Task["db:migrate:upgrade_plugin_migrations"].execute
			end
		end

		desc "Update migrations"
		task :migrations => :environment do
			# Update migrations for plugins
			plugins = Rails.plugins.select{|p| p.latest_migration}
			plugins_migrated = 0
			plugins.each do |plugin|
				if (plugin.name =~ /^pages/ || plugin.name =~ /^backstage/) && plugin.latest_migration != Engines::Plugin::Migrator.current_version(plugin)
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

	desc "Automated updates for newest version"
	task :update => ["update:files", "update:fix_plugin_migrations", "update:migrations"]
end

