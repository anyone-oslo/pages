class AddPinnedToTags < ActiveRecord::Migration[4.2]
  def change
    add_column :tags, :pinned, :boolean, default: false, null: false
  end
end
