# encoding: utf-8

class PageFile < ActiveRecord::Base
  include Dis::Model

  belongs_to :page

  validates_data_presence
  validates :content_type, presence: true
  validates :filename, presence: true
  validates :content_length, presence: true

  acts_as_list scope: :page

  localizable do
    attribute :description
  end

  before_validation :set_name_from_filename

  class << self
    def formats
      {
        'audio/mpeg'      => :mp3,
        'image/gif'       => :gif,
        'image/jpeg'      => :jpg,
        'image/jpg'       => :jpg,
        'image/pjpeg'     => :jpg,
        'image/png'       => :png,
        'application/pdf' => :pdf
      }
    end
  end

  def format?
    (self.content_type && self.class.formats.keys.include?(self.content_type)) ? true : false
  end

  def format
    self.class.formats[self.content_type]
  end

  def filename_extension
    if filename_extension?
      self.filename.match(/\.([^\.]+)$/)[1]
    else
      ""
    end
  end

  def filename_extension?
    self.filename =~ /\./
  end

  def to_param
    if filename_extension?
      "#{self.id}.#{self.filename_extension}"
    else
      "#{self.id}"
    end
  end

  private

  def set_name_from_filename
    if self.filename? && !self.name?
      self.name = File.basename(self.filename, ".*")
    end
  end
end
