# encoding: utf-8

require 'digest/sha1'
require 'tempfile'

namespace :db do
	desc "Copy production database to current environment"
	task :copy_from_production => :environment do
		db_config = YAML.load_file(File.join(RAILS_ROOT, 'config/database.yml'))
		temp_file = Tempfile.new(db_config[RAILS_ENV]['database'])
		puts "Dumping remote database... (this might take a while)"
		`mysqldump --add-drop-table --single-transaction --allow-keywords --hex-blob --quick -u #{db_config['production']['username']} -p#{db_config['production']['password']} -h #{db_config['production']['host']} --max_allowed_packet=100M #{db_config['production']['database']} > #{temp_file.path}`
		puts "Importing database dump"
		if db_config[RAILS_ENV]['password']
			`mysql -u #{db_config[RAILS_ENV]['username']} -p#{db_config[RAILS_ENV]['password']} -h #{db_config[RAILS_ENV]['host']} #{db_config[RAILS_ENV]['database']} < #{temp_file.path}`
		else
			`mysql -u #{db_config[RAILS_ENV]['username']} -h #{db_config[RAILS_ENV]['host']} #{db_config[RAILS_ENV]['database']} < #{temp_file.path}`
		end
		puts "Done!"
		temp_file.close!
	end
end