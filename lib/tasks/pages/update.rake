require 'find'
require 'open-uri'

namespace :pages do
	namespace :update do

		desc "Fix inheritance"
		task :fix_inheritance do
			def find_files(file_expression, options={})
				paths = []
				Find.find(".") do |path|
					gsubbed_path = path.gsub(/^\.?\/?/,'')
					Find.prune if options[:except] && gsubbed_path =~ options[:except]
					if gsubbed_path =~ file_expression && !(path =~ /\.git/)
						paths << path unless File.directory?(path)
					end
				end
				paths
			end
			
			find_files(%r%^app/controllers/.*\.rb%).each do |controller|
				plugin_controller = File.join('vendor/plugins/pages', controller)
				if File.exists?(plugin_controller)
					class_definition = File.read(plugin_controller).split(/\n/).first
					file_content = File.read(controller)
					patched_file_content = file_content.gsub(/class [\w:]+Controller( < [\w:]+)/, class_definition)
					unless patched_file_content == file_content
						puts "Patching file #{controller}.."
						File.open(controller, 'w') {|fh| fh.write(patched_file_content)}
					end
				end
			end
		end

		desc "Patch files"
		task :files do
			def find_files(file_expression, options={})
				paths = []
				Find.find(".") do |path|
					gsubbed_path = path.gsub(/^\.?\/?/,'')
					Find.prune if options[:except] && gsubbed_path =~ options[:except]
					if gsubbed_path =~ file_expression && !(path =~ /\.git/)
						paths << path unless File.directory?(path)
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
			# patch_files(
			# 	%r%^app/controllers/[\w\d\-_]*_controller\.rb%, 
			# 	/< ApplicationController/, 
			# 	"< FrontendController",
			# 	:except => %r%^app/controllers/(frontend|images|songs|newsletter)_controller\.rb%
			# ) do |files|
			# 	puts "Frontend controllers patched to inherit FrontendController: #{files.inspect}"
			# end
			patch_files %r%^script/[\w\d_\-\/]+%, /^#!\/usr\/bin\/ruby/, "#!/usr/bin/env ruby" do |files|
				puts "* Updated shebang in script files: #{files.inspect}"
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

			# Passenger/RVM
			if !File.exists?('config/setup_load_paths.rb')
				puts "* setup_load_paths.rb not found, installing default..."
				slp_template = File.join(File.dirname(__FILE__), '../../../template/config/setup_load_paths.rb')
				`cp #{slp_template} config/setup_load_paths.rb`
			end

			# Bundler
			if !File.exists?('Gemfile')
				puts "* Gemfile not found, installing default..."
				gemfile_template = File.join(File.dirname(__FILE__), '../../../template/Gemfile')
				`cp #{gemfile_template} Gemfile`
			end
			patch_files(
				%r%^config/boot\.rb%, 
				/^[\s]*Rails\.boot!/, 
				"class Rails::Boot\n  def run\n    load_initializer\n    Rails::Initializer.class_eval do\n      def load_gems\n        @bundler_loaded ||= Bundler.require :default, Rails.env\n      end\n    end\n    Rails::Initializer.run(:set_load_path)\n  end\nend\n\nRails.boot!",
				:unless_matches => /Bundler.require/
			) do |files|
				puts "* boot.rb patched for Bundler"
			end
			if !File.exists?('config/preinitializer.rb')
				preinit_template = File.join(File.dirname(__FILE__), '../../../template/config/preinitializer.rb')
				`cp #{preinit_template} config/preinitializer.rb`
				abort "\n* Updated for Bundler support, please run pages:update again."
			end
			
			if !File.exists?("app/assets")
				puts "* Assets folder not found, creating..."
				FileUtils.mkdir_p File.join(RAILS_ROOT, 'app/assets/javascripts')
				FileUtils.mkdir_p File.join(RAILS_ROOT, 'app/assets/stylesheets')
				`touch app/assets/javascripts/.gitignore`
				`touch app/assets/stylesheets/.gitignore`
				`git add app/assets/javascripts/.gitignore`
				`git add app/assets/stylesheets/.gitignore`
				`git mv public/javascripts/* app/assets/javascripts`
				`git mv public/stylesheets/* app/assets/stylesheets`
				Rake::Task["pages:assets:compile"].execute
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
		
		desc "Update gems"
		task :gems do
			puts "Updating Bundler..."
			`bundle install`
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
		task :all => ["update:files", "update:fix_inheritance", "update:gems", "update:fix_plugin_migrations", "update:migrations"]
	end 

	desc "Automated updates for newest version"
	task :update => ["update:submodules"] do
		puts "Submodules updated, running rake again"
		system "rake pages:update:all"
	end
end