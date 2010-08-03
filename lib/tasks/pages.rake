require 'find'
namespace :pages do
	
	namespace :error_reports do
		desc "Show error reports"
		task :list => :environment do
			require 'term/ansicolor'
			include Term::ANSIColor

			reports = []
			reports_dir = File.join(RAILS_ROOT, 'log/error_reports')
			if File.exists?(reports_dir)
				files = Dir.entries(reports_dir).select{|f| f =~ /\.yml$/}
				files.each do |f|
					if report = YAML.load_file(File.join(reports_dir, f)).merge({:sha1_hash => f.gsub(/\.yml$/, '')}) rescue nil
						reports << report
					end
				end
			end
			if reports.length > 1
				puts
				reports = reports.sort{|a, b| a[:timestamp] <=> b[:timestamp]}
				reports.each do |report|
					message = report[:message].strip.split("\n").first
					print "#{report[:timestamp]} ", "#{report[:sha1_hash]}".blue.bold, "\n"
					print "#{report[:url]}".green.bold, "\n"
					print "#{report[:params].inspect}\n".yellow
					print "#{message}\n\n"
				end
			else
				puts "No error reports found"
			end
		end
		
		desc "Clear all error reports"
		task :clear => :environment do
			reports_dir = File.join(RAILS_ROOT, 'log/error_reports')
			if File.exists?(reports_dir)
				files = Dir.entries(reports_dir).select{|f| f =~ /\.yml$/}
				files.each do |f|
					`rm #{File.join(reports_dir, f)}`
				end
			end
			puts "Error reports cleared"
		end
	end
	
	desc "Show error reports"
	task :error_reports => "pages:error_reports:list" do
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
		PagesCore::CacheSweeper.disable do
			Feed.find(:all).each do |feed|
				begin
					feed.refresh
				rescue
					puts "!!! Error parsing feed #{feed.url} - #{$!.to_s}"
				end
			end
		end
		PagesCore::CacheSweeper.sweep!
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
		
		create_options = {}
		create_options_file = File.join(RAILS_ROOT, 'config/create_options.yml')
		if File.exists?(create_options_file)
			create_options = YAML::load_file(create_options_file)
		end

		puts "Installing Pages..\n\n"
		
		puts "!!! WARNING !!! This will overwrite the application controller and several configuration files."
		print "Continue? "
		
		exit unless STDIN.readline.downcase =~ /^y/
		puts
		
		@site_name        = create_options[:name]             || get_input("Name of site (ie: My Awesome Site)")
		@site_domain      = create_options[:domain]           || get_input("Domain", @site_name.downcase.gsub(/[^\w\d]/,'')+".no")
		@app_name         = create_options[:app_name]         || get_input("App name", @site_domain.gsub(/\.[\w]+$/, ''))
		@mail_sender      = create_options[:mail_sender]      || get_input("Mail sender", "#{@site_name} <no-reply@#{@site_domain}>")
		@default_language = create_options[:default_language] || get_input("Default language", "English")
		
		puts
		
		@database_production  = create_options[:database_production]  || get_input("Production database", "#{@app_name}")
		@database_development = create_options[:database_development] || get_input("Development database", "#{@app_name}_dev")
		@database_test        = create_options[:database_test]        || get_input("Test database", "#{@app_name}_test")
		
		@forgery_secret = generate_key(34)
		@session_secret = generate_key(128)
		
		puts "\nGenerating files..."
		template_path = File.join(File.dirname(__FILE__), '../../template')
		Find.find(template_path) do |path|
			Find.prune if path =~ /\.git/
			if File.file?(path)
				file_path = path.gsub(Regexp.new("^#{Regexp.escape(template_path)}/?"),'')
				template = ERB.new(File.read(path))
				target_path = File.join(RAILS_ROOT, file_path)
				File.open(target_path, 'w+'){|fh| fh.write template.result}
			end
		end
		print "Create and migrate database? "
		if STDIN.readline.downcase =~ /^y/ 
			puts "Creating development database and migrations (this might take a while)..."
			`rake db:create`
			`script/generate plugin_migration pages`
			`git add db/migrate/*`
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
			puts "\nAll done. To set up the database and create the migrations, run the following commands and follow the instructions:"
			puts "\nrake db:create\nrake pages:update"
			puts
		end
		puts "When you're ready to deploy for the first time, run this command to set up the database and apache config:"
		puts "\ncap deploy:cold"
		puts
		if File.exists?(create_options_file)
			File.unlink(create_options_file)
		end
		`git add .`
	end

	namespace :update do
		desc "Patch files"
		task :files do
			def find_files(file_expression, options={})
				paths = []
				Find.find(".") do |path|
					gsubbed_path = path.gsub(/^\.?\/?/,'')
					Find.prune if options[:except] && gsubbed_path =~ options[:except]
					if gsubbed_path =~ file_expression && !(path =~ /\.git/)
						paths << path
					end
				end
				paths
			end
			def patch_files(file_expression, expression, sub, options={})
				updated_files = []
				find_files(file_expression, options).each do |path|
					file_content = File.read(path)
					skip_file = (options.has_key?(:unless_matches) && file_content =~ options[:unless_matches]) ? true : false
					patched_file_content = file_content.gsub(expression, sub)
					unless file_content == patched_file_content || skip_file
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
				abort "\n* Rails gem version updated to newest, stopping. Please run rake rails:update, then re-run this task to complete."
			end
			patch_files(
				%r%^config/environment.rb% , 
				/^Rails::Initializer\.run/, 
				"# Bootstrap Pages\nrequire File.join(File.dirname(__FILE__), '../vendor/plugins/pages/boot')\n\nRails::Initializer.run",
				:unless_matches => /vendor\/plugins\/pages\/boot/
			) do
				puts "* Added Pages engine bootstrapper"
			end
			patch_files %r%^config/environments/.*\.rb%, /^config\.action_view\.cache_template_loading/, "#config.action_view.cache_template_loading" do |files|
				puts "* config.action_view.cache_template_loading has been deprecated, commented out in #{files.inspect}."
			end
			patch_files %r%^config/environment\.rb%, /^[\s]*config\.action_controller\.session_store/, "\t#config.action_controller.session_store" do |files|
				puts "* ActiveRecord session store has been depreceated, commented out in #{files.inspect}."
			end
			patch_files(
				%r%^app/controllers/[\w\d\-_]*_controller\.rb%, 
				/< ApplicationController/, 
				"< FrontendController",
				:except => %r%^app/controllers/(frontend|images|songs|newsletter)_controller\.rb%
			) do |files|
				puts "Frontend controllers patched to inherit FrontendController: #{files.inspect}"
			end
			
			if !File.exists?('script/delayed_job')
				puts "Delayed job worker script not found, installing..."
				File.open('script/delayed_job', 'w') do |fh|
					fh.write("#!/usr/bin/env ruby\n")
					fh.write("require File.join(File.dirname(__FILE__), '../vendor/plugins/pages/lib/delayed_job_worker.rb')\n")
				end
				`chmod +x script/delayed_job`
				`git add script/delayed_job`
			end

			if !File.exists?('app/views/pages/templates')
				puts "Page template dir not found, moving old templates..."
				`mkdir app/views/pages/templates`
				find_files(%r%^app/views/pages/[\w\d\-_]+\.[\w\d\-_\.]+%).each do |path|
					new_path = path.split('/')
					filename = new_path.pop
					new_path << 'templates'
					new_path << filename
					new_path = new_path.join('/')
					`mv #{path} #{new_path}`
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
				`git add db/migrate/*`
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
		
		desc "Update submodules"
		task :submodules do
			puts "Updating submodules..."
			# Get origin base patch
			origin_base_url = `cd #{RAILS_ROOT}/vendor/plugins/pages && git remote -v | grep origin`.split(/\s+/)[1].gsub(/pages(\.git)?$/, '')

			required_plugins = %w{thinking-sphinx acts_as_list acts_as_tree dynamic_image engines recaptcha delayed_job}
			required_plugins.each do |plugin|
				unless File.exists?(File.join(RAILS_ROOT, "vendor/plugins/#{plugin}"))
					puts "Missing plugin: #{plugin} .. installing.."
					`cd #{RAILS_ROOT} && git submodule add #{origin_base_url}/#{plugin}.git vendor/plugins/#{plugin}`
				end
			end
			
			`git submodule update --init`
			`git submodule foreach 'git checkout -q master'`
			`git submodule foreach 'git pull'`
		end
		
		desc "Run all update tasks"
		task :all => ["update:files", "update:fix_plugin_migrations", "update:migrations"]
	end 

	desc "Automated updates for newest version"
	task :update => ["update:submodules"] do
		puts "Submodules updated, running rake again"
		system "rake pages:update:all"
	end
	#, "update:files", "update:fix_plugin_migrations", "update:migrations"]
end

