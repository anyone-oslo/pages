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

  after_save ThinkingSphinx::RealTime.callback_for(:page_file)

  class << self
    def formats
      {
        "audio/mpeg"      => :mp3,
        "image/gif"       => :gif,
        "image/jpeg"      => :jpg,
        "image/jpg"       => :jpg,
        "image/pjpeg"     => :jpg,
        "image/png"       => :png,
        "application/pdf" => :pdf
      }
    end
  end

  def format?
    content_type && self.class.formats.keys.include?(content_type)
  end

  def format
    self.class.formats[content_type]
  end

  def filename_extension
    if filename_extension?
      filename.match(/\.([^\.]+)$/)[1]
    else
      ""
    end
  end

  def filename_extension?
    filename =~ /\./
  end

  def to_param
    if filename_extension?
      "#{id}-#{content_hash}.#{filename_extension}"
    else
      "#{id}-#{content_hash}"
    end
  end

  delegate :published, to: :page

  private

  def set_name_from_filename
    self.name = File.basename(filename, ".*") if filename? && !name?
  end
end
