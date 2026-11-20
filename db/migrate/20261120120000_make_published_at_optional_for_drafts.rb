# frozen_string_literal: true

class MakePublishedAtOptionalForDrafts < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      UPDATE pages SET published_at = NULL
      WHERE status IN (0, 1)
        AND published_at >= created_at - interval '1 hour'
        AND published_at <= created_at + interval '1 minute'
    SQL

    execute <<~SQL.squish
      UPDATE pages SET published_at = created_at
      WHERE status = 2 AND published_at IS NULL
    SQL

    add_check_constraint :pages, "status <> 2 OR published_at IS NOT NULL",
                         name: "pages_published_at_required"
  end

  def down
    remove_check_constraint :pages, name: "pages_published_at_required"

    execute <<~SQL.squish
      UPDATE pages SET published_at = created_at WHERE published_at IS NULL
    SQL
  end
end
