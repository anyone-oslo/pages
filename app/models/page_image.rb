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
end
