# encoding: utf-8

require "digest/sha1"
require "tempfile"

namespace :db do
  desc "Convert timestamps to UTC"
  task convert_to_utc: :environment do
    tables = ActiveRecord::Base.connection.execute("SHOW TABLES")
    tables.each do |table_row|
      table = table_row.first
      columns = ActiveRecord::Base.connection.execute("DESC `#{table}`")
      columns.each do |column_row|
        column = column_row[0]
        type = column_row[1]
        next unless %w(datetime time timestamp).include?(type)
        puts "Converting #{table}: #{column} (#{type})"
        ActiveRecord::Base.connection.execute(
          "UPDATE `#{table}` SET `#{column}` = " \
          "DATE_SUB(`#{column}`, INTERVAL 1 HOUR)"
        )
      end
    end
  end

  desc "Copy production database to current environment"
  task copy_from_production: :environment do
    db_config = YAML.load_file(Rails.root.join("config", "database.yml"))
    temp_file = Tempfile.new(db_config[Rails.env]["database"])

    export_opts = "--add-drop-table --single-transaction --allow-keywords " \
                  "--hex-blob --quick " \
                  "-u #{db_config['production']['username']} " \
                  "-p#{db_config['production']['password']} " \
                  "-h #{db_config['production']['host']} " \
                  "--max_allowed_packet=100M " \
                  "#{db_config['production']['database']}"

    import_opts = if db_config[Rails.env]["password"]
                    "-u #{db_config[Rails.env]['username']} " \
                    "-p#{db_config[Rails.env]['password']} " \
                    "-h #{db_config[Rails.env]['host']} " \
                    "#{db_config[Rails.env]['database']}"
                  else
                    "-u #{db_config[Rails.env]['username']} " \
                    "-h #{db_config[Rails.env]['host']} " \
                    "#{db_config[Rails.env]['database']}"
                  end

    puts "Dumping remote database... (this might take a while)"
    `mysqldump #{export_opts}  > #{temp_file.path}`

    puts "Importing database dump"
    `mysql #{import_opts} < #{temp_file.path}`

    puts "Done!"
    temp_file.close!
  end

  desc "Fixes double UTF-8 encoding"
  task fix_double_encoding: :environment do
    config = Rails.configuration.database_configuration[Rails.env]

    temp_file = Tempfile.new(config["database"])

    export_cmd = if config["password"]
                   "mysqldump -u #{config['username']} -p#{config['password']}"
                 else
                   "mysqldump -u #{config['username']}"
                 end

    export_opts = "--opt --quote-names --skip-set-charset " \
                  "--default-character-set=latin1 " \
                  "-h #{config['host']} --max_allowed_packet=100M " \
                  "#{config['database']}"

    `#{export_cmd} #{export_opts} > #{temp_file.path}`

    puts "Dumping database..."

    mysql_command = if config["password"]
                      "mysql -u #{config['username']} -p#{config['password']}"
                    else
                      "mysql -u #{config['username']}"
                    end

    import_opts = "-h #{config['host']} --default-character-set=utf8 " \
                  "#{config['database']}"

    puts "Importing database dump"
    `#{mysql_command} #{import_opts} < #{temp_file.path}`

    puts "Done!"
    temp_file.close!
  end
end
