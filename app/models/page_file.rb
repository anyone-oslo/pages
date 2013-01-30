# encoding: utf-8

class PageFile < ActiveRecord::Base

  FORMATS = {
    'audio/mpeg'      => :mp3,
    'image/gif'       => :gif,
    'image/jpeg'      => :jpg,
    'image/jpg'       => :jpg,
    'image/pjpeg'     => :jpg,
    'image/png'       => :png,
    'application/pdf' => :pdf
  }

  belongs_to :page
  belongs_to :binary, :dependent => :destroy

  validates_presence_of :binary_id

  acts_as_list :scope => :page

  acts_as_textable [ "description" ], :allow_any => false

  validate do |file|
    file.name = File.basename(file.filename, ".*") unless file.name?
    file.content_type = 'image/jpeg' if file.content_type == 'image/x-citrix-pjpeg' # Fuck you, Citrix
    file.content_type = 'image/gif'  if file.content_type == 'image/x-citrix-gif'   # Fuck you, Citrix
  end

  def file=(file)
    self.filename     = file.original_filename rescue File.basename( file.path )
    self.filesize     = file.size
    self.content_type = file.content_type
    self.binary       = Binary.create unless self.binary
    self.binary.data  = file.read
    self.binary.save
  end

  def data
    self.binary.data
  end

  def format?
    (self.content_type && FORMATS.keys.include?(self.content_type)) ? true : false
  end

  def format
    FORMATS[self.content_type]
  end

end
