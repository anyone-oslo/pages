class PageImage < ActiveRecord::Base

	belongs_to :page
	belongs_to_image :image, :dependent => :destroy
	
	validates_presence_of :page_id, :image_id
	
	delegate :name, :description, :byline, :to => :image
	
	acts_as_list :scope => :page
	
	after_save do |page_image|
		if page_image.primary_changed?

			# Make sure only one PageImage can be the primary,
			# then update image_id on the page.
			if page_image.primary?
				PageImage.update_all(
					'`primary` = 0',
					['page_id = ? AND id != ?', page_image.page_id, page_image.id]
				)
				page_image.page.update_attribute(:image_id, page_image.image.id)
				
			# Clear image_id on the page if primary is toggled off
			else
				page_image.page.update_attribute(:image_id, nil)
			end
		end
	end

end
