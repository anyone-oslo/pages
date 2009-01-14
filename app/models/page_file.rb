class PageFile < ActiveRecord::Base

	belongs_to :page
	belongs_to :binary, :dependent => :destroy
	
	validates_presence_of :binary_id
	
	acts_as_list :scope => :page

	acts_as_textable [ "description" ], :allow_any => false

	validate do |file|
		file.name = File.basename( file.filename, ".*" ) unless file.name?
	end
	
	def file=( file )
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

end
