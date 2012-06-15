require 'find'
require 'open-uri'

namespace :pages do

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
		template_path = File.join(File.dirname(__FILE__), '../../../template')
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
			`bundle exec rake db:create`
			`script/generate plugin_migration pages`
			`git add db/migrate/*`
			`bundle exec rake db:migrate`
			puts "\n"
			puts "All done."
		else
			puts "\nAll done. To set up the database and create the migrations, run the following commands and follow the instructions:"
			puts "\nbundle exec rake db:create\nbundle exec rake pages:update"
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

end