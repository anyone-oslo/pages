# encoding: utf-8

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

			# Update controllers
			find_files(%r%^app/controllers/.*\.rb%).each do |controller|
				plugin_controller = File.join('vendor/plugins/pages', controller)
				if File.exists?(plugin_controller)
					class_definition = File.read(plugin_controller).split(/\n/).select{|l| l =~ /class/}.first
					file_content = File.read(controller)
					patched_file_content = file_content.gsub(/class [\w:]+Controller( < [\w:]+)/, class_definition)
					unless patched_file_content == file_content
						puts "Patching file #{controller}.."
						File.open(controller, 'w') {|fh| fh.write(patched_file_content)}
					end
				end
			end

			# Update helpers
			find_files(%r%^app/helpers/.*\.rb%).each do |helper|
				plugin_helper = File.join('vendor/plugins/pages', helper)
				if File.exists?(plugin_helper)
					helper_name = helper.gsub(/.*\/app\/helpers\//, '').gsub(/\.rb$/, '').camelize
					includes = File.readlines(plugin_helper).select{|l| l =~ /^\s*include /}
					includes.map!{|i| i.match(/\s*include\s+([\w\d:]+)/)[1]}
					file_content = File.read(helper)
					patched_file_content = file_content.dup
					includes.reverse.each do |include_module|
						unless file_content =~ Regexp.new('include\s+' + include_module)
							patched_file_content.gsub!(Regexp.new('module\s+' + helper_name)) do
								"module #{helper_name}\n\tinclude #{include_module}"
							end
						end
					end

					unless patched_file_content == file_content
						puts "Patching file #{helper}.."
						File.open(helper, 'w') {|fh| fh.write(patched_file_content)}
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

			# Rename application.rb to application_controller.rb
			if File.exists?('app/controllers/application.rb')
				puts "* Renaming application.rb"
				`mv app/controllers/application.rb app/controllers/application_controller.rb`
			end

			# Update the Rakefile
			patch_files(
				%r%^Rakefile% ,
				/^require 'rake\/rdoctask'/,
				"require 'rdoc/task'"
			) do
				puts "* Updated RDoc require in Rakefile"
			end

			# Add the Pages bootstrapper
			patch_files(
				%r%^config/environment.rb% ,
				/^Rails::Initializer\.run/,
				"# Bootstrap Pages\nrequire File.join(File.dirname(__FILE__), '../vendor/plugins/pages/boot')\n\nRails::Initializer.run",
				:unless_matches => /vendor\/plugins\/pages\/boot/
			) do
				puts "* Added Pages engine bootstrapper"
			end

			# Remove the Engines bootstrapper
			patch_files(
				%r%^config/environment.rb% ,
				/^\s*# Bootstrap Engines[\s]+require File\.join\(File\.dirname\(__FILE__\), '\.\.\/vendor\/plugins\/engines\/boot'\)[\s]*/,
				"\n"
			) do
				puts "* Removed Engines bootstrapper"
			end

			# Remove the RAILS_GEM_VERSION
			patch_files(
				%r%^config/environment.rb% ,
				/^\s*# Specifies gem version of Rails to use when vendor\/rails is not present[\s]*RAILS_GEM_VERSION = '[\d\.]+' unless defined\? RAILS_GEM_VERSION[\s]*/,
				"\n"
			) do
				puts "* Removed RAILS_GEM_VERSION"
			end

			# Rename :session_key to :key
			patch_files(
				%r%^config/environment.rb% ,
				/:session_key[\s]+\=\>/,
				":key         =>"
			) do
				puts "* Renamed :session_key to :key"
			end

			# Remove plugin routes
			patch_files(
				%r%^config/routes.rb% ,
				/^[ \t]*(# Plugin routes|map.from_plugin :[\w_]+)[\n\r]*/,
				""
			) do
				puts "* Removed plugin routes"
			end

			# Remove deprecated configuration
			patch_files %r%^config/environments/.*\.rb%, /^config\.action_view\.cache_template_loading/, "#config.action_view.cache_template_loading" do |files|
				puts "* config.action_view.cache_template_loading has been deprecated, commented out in #{files.inspect}."
			end
			patch_files %r%^config/environment\.rb%, /^[\s]*config\.action_controller\.session_store/, "\t#config.action_controller.session_store" do |files|
				puts "* ActiveRecord session store has been depreceated, commented out in #{files.inspect}."
			end

			# Set the correct RAILS_GEM_VERSION
			#patch_files %r%^config/environment.rb% , /^[\s]*RAILS_GEM_VERSION[\s]*=[\s]*'([\d\.]*)'/, "RAILS_GEM_VERSION = '2.3.14'" do
			#	abort "\n* Rails gem version updated to newest, stopping. Please run bundler, then re-run this task to complete."
			#end

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

			# Remove old migrations
			deleted_migrations = []
			Dir.entries('db/migrate').each do |migration|
				if migration =~ /_to_version_[\d]+\.rb$/
					deleted_migrations << migration
					`rm db/migrate/#{migration}`
				end
			end
			puts "* Deleted #{deleted_migrations.length} old engine migrations"

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

		desc "Update gems"
		task :gems do
			puts "Updating Bundler..."
			`bundle install`
		end

		desc "Fix plugin migrations"
		task :fix_migrations => :environment do
			Dir.entries(File.join(RAILS_ROOT, 'vendor/plugins')).each do |plugin|
				plugin_root = File.join(RAILS_ROOT, 'vendor/plugins', plugin)
				if File.exists?(old_migrations = File.join(plugin_root, 'config/old_migrations.yml'))
					YAML::load_file(old_migrations).each_with_index do |migration, i|
						old_migration = "#{i + 1}-#{plugin}"
						query = "UPDATE schema_migrations SET version = '#{migration}' WHERE version = '#{old_migration}'"
						ActiveRecord::Base.connection.execute(query)
					end
				end
			end
		end

		desc "Update migrations"
		task :migrations => :environment do
			new_migrations = []
			Dir.entries(File.join(RAILS_ROOT, 'vendor/plugins')).each do |plugin|
				plugin_root = File.join(RAILS_ROOT, 'vendor/plugins', plugin)
				if File.exists?(template_dir = File.join(plugin_root, 'template/db/migrate'))
					Dir.entries(template_dir).select{|f| f =~ /^\d+/}.each do |migration|
						unless File.exists?(File.join(RAILS_ROOT, 'db/migrate', migration))
							`cp #{File.join(template_dir, migration)} #{File.join(RAILS_ROOT, 'db/migrate', migration)}`
							new_migrations << migration
						end
					end
				end
			end
			if new_migrations.any?
				puts "\n#{new_migrations.length} new migrations added, now run rake db:migrate"
			end
		end

		desc "Update submodules"
		task :remove_old_submodules do
			puts "Removing old submodules..."
			%w{acts_as_list acts_as_tree delayed_job dynamic_image engines recaptcha thinking-sphinx}.each do |plugin|
				if File.exists?("vendor/plugins/#{plugin}")
					`rm -rf vendor/plugins/#{plugin}`
					`git rm vendor/plugins/#{plugin}`

					# Remove from .gitmodules
					if File.exists?('.gitmodules')
						gitmodules = File.readlines('.gitmodules').reject{|l| l =~ Regexp.new(plugin)}.join
						File.open('.gitmodules', 'w'){|fh| fh.write gitmodules}
					end

					# Remove from .git/config
					if File.exists?('.git/config')
						git_config = File.readlines('.git/config').reject{|l| l =~ Regexp.new(plugin)}.join
						File.open('.git/config', 'w'){|fh| fh.write git_config}
					end
				end
			end
		end

		desc "Updates submodules"
		task :submodules do
			puts "Updating submodules..."
			`git submodule update --init`
			`git submodule foreach 'git checkout -q master'`
			`git submodule foreach 'git pull'`
		end

		desc "Run all update tasks"
		task :all => [
			"update:remove_old_submodules",
			"update:files",
			"update:fix_inheritance",
			"update:fix_migrations",
			"update:migrations",
			"update:gems"
		]
	end

	desc "Automated updates for newest version"
	task :update => ["update:submodules"] do
		puts "Submodules updated, running rake again"
		system "bundle exec rake pages:update:all"
	end
end