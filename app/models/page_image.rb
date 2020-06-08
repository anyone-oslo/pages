# frozen_string_literal: true

class PageImage < ActiveRecord::Base
  include PagesCore::Sweepable

  belongs_to :page
  belongs_to_image :image

  validates :page_id, presence: true

  accepts_nested_attributes_for :image
  validates_associated :image

  acts_as_list scope: %i[page primary]

  localizable

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
