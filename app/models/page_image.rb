class PageImage < ActiveRecord::Base

	belongs_to :page
	belongs_to_image :image#, :dependent => :destroy

	validates_presence_of :page_id, :image_id

	DELEGATED_ATTRIBUTES = [:name, :description, :byline, :crop_start, :crop_size]
	DELEGATED_ATTRIBUTES.each{|a| attr_accessor a}

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

		image_attributes = {}
		DELEGATED_ATTRIBUTES.each do |attribute|
			page_image_attribute = page_image.send(attribute)
			if !page_image_attribute.nil? && page_image_attribute != page_image.image.attributes[attribute]
				image_attributes[attribute] = page_image_attribute
			end
		end
		if image_attributes.length > 0
			if image_attributes[:crop_size] && image_attributes[:crop_size] != page_image.image.original_size
				image_attributes[:cropped] = true
			end
			page_image.image.update_attributes(image_attributes)
		end
	end

	after_destroy do |page_image|
		if page_image.primary?
			page_image.page.update_attribute(:image_id, nil)
		end
	end

	class << self
		def cleanup!
			self.find(:all).each do |page_image|
				page_image.destroy unless page_image.image
			end
		end
	end

	def name
		@name ||= (self.image ? self.image.name : nil)
	end

	def byline
		@byline ||= (self.image ? self.image.byline : nil)
	end

	def description
		@description ||= (self.image ? self.image.description : nil)
	end

	def crop_start
		@crop_start ||= (self.image ? self.image.crop_start : nil)
	end

	def crop_size
		@crop_size ||= (self.image ? self.image.crop_size : nil)
	end

	def to_json(options={})
		options = {
			:include => [:image]
		}.merge(options)
		super(options)
	end

end
