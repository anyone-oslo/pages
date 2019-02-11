class PageFile < ActiveRecord::Base
  belongs_to :page
  belongs_to :attachment

  acts_as_list scope: :page

  localizable do
  end

  delegate :published, to: :page

  def attachment
    super.localize(locale)
  end
end
