class RemovePageContentOrder < ActiveRecord::Migration
  def change
    remove_column :pages, :content_order, :string
  end
end
