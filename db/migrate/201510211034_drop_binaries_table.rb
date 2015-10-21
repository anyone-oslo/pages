class DropBinariesTable < ActiveRecord::Migration
  def change
    drop_table :binaries do |t|
      t.string "sha1_hash"
    end
  end
end
