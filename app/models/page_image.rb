# encoding: utf-8

class PageImage < ActiveRecord::Base
  include PagesCore::Sweepable

  belongs_to :page
  belongs_to_image :image

  validates :page_id, presence: true

  accepts_nested_attributes_for :image
  validates_associated :image

  acts_as_list scope: %i[page primary]

  localizable

  validate do |page_image|
    if page_image.page && page_image.page.page_images.count < 1
      page_image.primary = true
    end
  end

  before_save :detect_primary_change
  after_save :update_primary
  after_destroy :unset_page_image_on_destroy

  class << self
    def cleanup!
      all.find_each do |page_image|
        page_image.destroy unless page_image.image
      end
    end
  end

  def image
    super.localize!(locale)
  end

  def to_json(options = {})
    options = { include: [:image] }.merge(options)
    super(options)
  end

  private

  def detect_primary_change
    @primary_change = primary_changed?
  end

  def update_primary
    return unless @primary_change
    # Make sure only one PageImage can be the primary,
    # then update image_id on the page.
    if primary?
      page
        .page_images
        .where("id != ?", id)
        .find_each { |p| p.update(primary: false) }
      page.update(image_id: image_id)

    # Clear image_id on the page if primary is toggled off
    else
      page.update(image_id: nil)
    end
    @primary_change = false
  end

  def unset_page_image_on_destroy
    return unless primary?
    page.update(image_id: nil)
  end
end
