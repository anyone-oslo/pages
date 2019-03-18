class FixPageFileIds < ActiveRecord::Migration[5.0]
  def change
    attachment_id = execute(
      "SELECT MAX(attachment_id) AS max_id FROM page_files"
    )[0]["max_id"]
    pf_id = execute("SELECT MAX(id) AS max_id FROM page_files")[0]["max_id"]


    if attachment_id && pf_id
      max_id = [attachment_id, pf_id].max

      execute("UPDATE page_files SET id = id + #{max_id + 1}")
      execute("UPDATE page_files SET id = attachment_id")
      execute("ALTER SEQUENCE page_files_id_seq RESTART WITH #{attachment_id + 1}")

      PageFile.all.each { |pf| pf.touch }
    end
  end
end
