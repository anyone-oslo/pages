class PageImage < ActiveRecord::Base

	belongs_to :page
	belongs_to_image :image, :dependent => :destroy

	validates_presence_of :page_id, :image_id

	delegate :name, :name=, :description, :description=, :byline, :byline=, :to => :image_or_new

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
				page_image.page.update_attribute(:image_id, page_image.image_id)

			# Clear image_id on the page if primary is toggled off
			else
				page_image.page.update_attribute(:image_id, nil)
			end
		end
	end

	class << self
		def cleanup!
			self.find(:all).each do |page_image|
				page_image.destroy unless page_image.image
			end
		end
	end

	def image_or_new
		self.image ||= Image.new
	end

	def to_json(options={})
		options = {
			:include => [:image]
		}.merge(options)
		super(options)
	end

end
