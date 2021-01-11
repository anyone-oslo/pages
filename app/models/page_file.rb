# frozen_string_literal: true

class PageFile < ApplicationRecord
  include PagesCore::Sweepable

  belongs_to :page
  belongs_to :attachment

  acts_as_list scope: :page

  accepts_nested_attributes_for :attachment

  localizable

  delegate :published, to: :page

  def attachment
    super&.localize!(locale)
  end

  def name
    attachment&.name
  end

  def description
    attachment&.description
  end

  def filename
    attachment&.filename
  end

  def format?
    attachment&.format?
  end

  def format
    attachment&.format
  end

  def to_param
    return id unless attachment

    if attachment.filename_extension?
      "#{id}-#{attachment.content_hash}.#{attachment.filename_extension}"
    else
      "#{id}-#{attachment.content_hash}"
    end
  end
end
