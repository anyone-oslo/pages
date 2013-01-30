# encoding: utf-8

class RenamePageImages < ActiveRecord::Migration
  def self.up
    rename_table :images_pages, :page_images

    # Add the missing primary key
    execute "ALTER TABLE `page_images`
             ADD COLUMN `id` INT(11) AUTO_INCREMENT NOT NULL FIRST,
             ADD PRIMARY KEY(`id`)"
    
    add_column :page_images, :position, :integer
    add_column :page_images, :primary, :boolean, :default => false, :null => false
    
    add_index  :page_images, :page_id
    add_index  :page_images, [:page_id, :primary]

    # Load all pages with images
    pages = (
      PageImage.find_by_sql('SELECT DISTINCT `page_id` FROM `page_images`').map{|pi| Page.find(pi.page_id)} + 
      Page.find(:all, :conditions => ['image_id IS NOT NULL'])
    ).uniq
    
    # Regenerate page images in sequence
    ActiveRecord::Base.transaction do
      pages.each do |page|
        page.page_images.create(:image_id => page.image_id, :primary => true) if page.image_id?
        page.page_images.find(:all, :order => '`primary` DESC, image_id ASC').each_with_index do |pi, i|
          pi.update_attribute(:position, i + 1)
        end
      end
    end
    
    PageImage.cleanup!
  end

  def self.down
    remove_index  :page_images, [:page_id, :primary]
    remove_index  :page_images, :page_id
    remove_column :page_images, :primary
    remove_column :page_images, :position
    remove_column :page_images, :id
    rename_table  :page_images, :images_pages
  end
end
