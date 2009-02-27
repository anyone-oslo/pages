require 'find'
namespace :pages do
	
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
	
	desc "Autopublish due pages"
	task :autopublish => :environment do
		published = Page.autopublish!
		puts "Autopublished #{published.length} pages"
	end
	
	desc "Perform routine maintenance"
	task :maintenance => [:autopublish, :clean_sessions, :refresh_feeds, :deliver_mailings] do
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
	
	desc "Install pages"
	task :install do
		require 'erb'

		def get_input(label, default_value=nil)
			if default_value
				print "#{label} [#{default_value}]: "
			else
				print "#{label}: "
			end
			default_value ||= ""
			input = STDIN.readline.strip
			(input.strip.empty?) ? default_value : input
		end
		def generate_key(length)
			pool = [0..9,'a'..'z','A'..'Z'].map{|r| r.to_a}.flatten
			(0...length).to_a.map { pool[rand(pool.length)].to_s }.join
		end

		puts "Installing Pages..\n\n"
		
		puts "!!! WARNING !!!"
		puts "This will overwrite the application controller and several configuration files."
		print "Continue? "
		
		exit unless STDIN.readline.downcase =~ /^y/
		puts
		
		@site_name        = get_input("Name of site (ie: My Awesome Site)", "My Awesome Site")
		@site_domain      = get_input("Domain", @site_name.downcase.gsub(/[^\w\d]/,'')+".no")
		@app_name         = get_input("App name", @site_domain.gsub(/\.[\w]+$/, ''))
		@mail_sender      = get_input("Mail sender", "#{@site_name} <no-reply@#{@site_domain}>")
		@default_language = get_input("Default language", "English")
		
		puts
		
		@database_production  = get_input("Production database", "#{@app_name}")
		@database_development = get_input("Development database", "#{@app_name}_dev")
		@database_test        = get_input("Test database", "#{@app_name}_test")
		
		@forgery_secret = generate_key(34)
		@session_secret = generate_key(128)
		
		puts "\nGenerating files..."
		template_path = File.join(File.dirname(__FILE__), '../../template')
		Find.find(template_path) do |path|
			if File.file?(path)
				file_path = path.gsub(Regexp.new("^#{Regexp.escape(template_path)}/?"),'')
				template = ERB.new(File.read(path))
				target_path = File.join(RAILS_ROOT, file_path)
				File.open(target_path, 'w+'){|fh| fh.write template.result}
			end
		end
		print "Create and migrate database? "
		if STDIN.readline.downcase =~ /^y/ 
			puts "Creating development database and migrations..."
			`rake db:create`
			`script/generate plugin_migration pages`
			`svn add db/migrate/*`
			`rake db:migrate`
			puts "Starting server..."
			new_thread = Thread.new do
				sleep(5)
				`open http://localhost:3000/admin`
			end
			`ruby script/server`
			new_thread.join
			puts "\n"
			puts "All done."
		else
			puts "\nAll done. To set up the database and create the migrations, do:"
			puts "\nrake db:create\nrake pages:update"
			puts "\nand follow the instructions."
			puts
		end
	end

	namespace :update do
		desc "Patch files"
		task :files do
			def find_files(file_expression)
				paths = []
				Find.find(".") do |path|
					if path.gsub(/^\.?\/?/,'') =~ file_expression && !(path =~ /\.svn/)
						paths << path
					end
				end
				paths
			end
			def patch_files(file_expression, expression, sub)
				updated_files = []
				find_files(file_expression).each do |path|
					file_content = File.read(path)
					patched_file_content = file_content.gsub(expression, sub)
					unless file_content == patched_file_content
						puts "Patching file #{path}.."
						updated_files << path
						File.open(path, 'w') {|fh| fh.write(patched_file_content)}
					end
				end
				if updated_files.length > 0
					yield updated_files if block_given?
				end
			end
			patch_files %r%^config/environment.rb% , /^[\s]*RAILS_GEM_VERSION[\s]*=[\s]*'([\d\.]*)'/, "RAILS_GEM_VERSION = '2.2.2'" do
				abort "\nRails gem version updated to newest, stopping. Please run rake rails:update, then re-run this task to complete."
			end
			patch_files %r%^config/environments/.*\.rb%, /^config\.action_view\.cache_template_loading/, "#config.action_view.cache_template_loading" do |files|
				puts "config.action_view.cache_template_loading has been deprecated, commented out in #{files.inspect}."
			end
			patch_files %r%^app/controllers/[\w\d\-_]*_controller\.rb%, /< ApplicationController/, "< FrontendController" do |files|
				puts "Frontend controllers patched to inherit FrontendController: #{files.inspect}"
			end
			
			#config.action_view.cache_template_loading
			if !File.exists?('app/views/pages/templates')
				puts "Page template dir not found, moving old templates..."
				`svn mkdir app/views/pages/templates`
				find_files(%r%^app/views/pages/[\w\d\-_]+\.[\w\d\-_\.]+%).each do |path|
					new_path = path.split('/')
					filename = new_path.pop
					new_path << 'templates'
					new_path << filename
					new_path = new_path.join('/')
					`svn mv #{path} #{new_path}`
				end
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

		desc "Patch routes for Rails 2.0"
		task :patch_routes => :environment do
			require 'routepatcher'
			dir = File.join(File.dirname(__FILE__),'..','..','..','..','..')
			patcher = RoutePatcher.new( dir )
			patcher.register_prefix( [ 'admin', 'pages' ] )
			patcher.patch!
		end
	end 

	desc "Automated updates for newest version"
	task :update => ["update:files", "update:fix_plugin_migrations", "update:migrations"]
end

