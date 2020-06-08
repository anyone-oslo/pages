# frozen_string_literal: true

class FixPageFileIds < ActiveRecord::Migration[5.0]
  def change
    attachment_id = max_id(:attachment_id, :page_files)
    pf_id = max_id(:id, :page_files)

    return unless attachment_id && pf_id

    max_id = [attachment_id, pf_id].max

    execute("UPDATE page_files SET id = id + #{max_id + 1}")
    execute("UPDATE page_files SET id = attachment_id")

    PageFile.all.each(&:touch)
  end

  def max_id(attr, table)
    query = "SELECT MAX(#{attr}) AS max_id FROM #{table}"
    execute(query)[0]["max_id"]
  end
end
