# encoding: utf-8

require 'digest/sha1'
require 'tempfile'

namespace :db do
  desc "Convert timestamps to UTC"
  task :convert_to_utc => :environment do
    tables = ActiveRecord::Base.connection.execute("SHOW TABLES")
    tables.each do |table_row|
      table = table_row.first
      columns = ActiveRecord::Base.connection.execute("DESC `#{table}`")
      columns.each do |column_row|
        column = column_row[0]
        type = column_row[1]
        if ["datetime", "time", "timestamp"].include?(type)
          puts "Converting #{table}: #{column} (#{type})"
          sql = "UPDATE `#{table}` SET `#{column}` = DATE_SUB(`#{column}`, INTERVAL 1 HOUR)"
          ActiveRecord::Base.connection.execute(sql)
        end
      end
    end
  end

  desc "Copy production database to current environment"
  task :copy_from_production => :environment do
    db_config = YAML.load_file(Rails.root.join('config', 'database.yml'))
    temp_file = Tempfile.new(db_config[Rails.env]['database'])
    puts "Dumping remote database... (this might take a while)"
    `mysqldump --add-drop-table --single-transaction --allow-keywords --hex-blob --quick -u #{db_config['production']['username']} -p#{db_config['production']['password']} -h #{db_config['production']['host']} --max_allowed_packet=100M #{db_config['production']['database']} > #{temp_file.path}`
    puts "Importing database dump"
    if db_config[Rails.env]['password']
      `mysql -u #{db_config[Rails.env]['username']} -p#{db_config[Rails.env]['password']} -h #{db_config[Rails.env]['host']} #{db_config[Rails.env]['database']} < #{temp_file.path}`
    else
      `mysql -u #{db_config[Rails.env]['username']} -h #{db_config[Rails.env]['host']} #{db_config[Rails.env]['database']} < #{temp_file.path}`
    end
    puts "Done!"
    temp_file.close!
  end
end
