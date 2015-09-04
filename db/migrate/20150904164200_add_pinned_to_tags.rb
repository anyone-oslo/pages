class AddPinnedToTags < ActiveRecord::Migration
  def change
    add_column :tags, :pinned, :boolean, default: false, null: false
  end
end
