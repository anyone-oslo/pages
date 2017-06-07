class DropBinariesTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :binaries do |t|
      t.string "sha1_hash"
    end
  end
end
