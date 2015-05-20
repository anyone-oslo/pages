class AddMetaImageToPage < ActiveRecord::Migration
  def change
    add_column :pages, :meta_image_id, :integer
  end
end
