# encoding: utf-8

class PageImage < ActiveRecord::Base
  belongs_to :page
  belongs_to_image :image

  validates_presence_of :page_id

  accepts_nested_attributes_for :image
  validates_associated :image

  acts_as_list scope: :page

  localizable

  validate do |page_image|
    if page_image.page && page_image.page.page_images.count < 1
      page_image.primary = true
    end
  end

  after_save do |page_image|
    if page_image.primary_changed?

      # Make sure only one PageImage can be the primary,
      # then update image_id on the page.
      if page_image.primary?
        PageImage.where
        page_image.page
          .page_images
          .where("id != ?", page_image.id)
          .update_all(primary: false)
        page_image.page.update(image_id: page_image.image_id)

      # Clear image_id on the page if primary is toggled off
      else
        page_image.page.update(image_id: nil)
      end
    end
  end

  after_destroy do |page_image|
    page_image.page.update(image_id: nil) if page_image.primary?
  end

  class << self
    def cleanup!
      all.each do |page_image|
        page_image.destroy unless page_image.image
      end
    end
  end

  def image
    super.localize(locale)
  end

  def to_json(options = {})
    options = { include: [:image] }.merge(options)
    super(options)
  end
end
