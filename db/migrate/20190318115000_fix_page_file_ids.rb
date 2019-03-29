class FixPageFileIds < ActiveRecord::Migration[5.0]
  def change
    attachment_id = max_id(:attachment_id, :page_files)
    pf_id = max_id(:id, :page_files)

    if attachment_id && pf_id
      max_id = [attachment_id, pf_id].max

      execute("UPDATE page_files SET id = id + #{max_id + 1}")
      execute("UPDATE page_files SET id = attachment_id")
      if mysql2?
        execute(
          "ALTER SEQUENCE page_files_id_seq RESTART WITH #{attachment_id + 1}"
        )
      end

      PageFile.all.each { |pf| pf.touch }
    end
  end

  def max_id(attr, table)
    query = "SELECT MAX(#{attr}) AS max_id FROM #{table}"
    if mysql2?
      execute(query).first[0]
    else
      execute(query)[0]["max_id"]
    end
  end

  def mysql2?
    Object.const_defined?("ActiveRecord::ConnectionAdapters::Mysql2Adapter") &&
      connection.instance_of?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
  end
end
