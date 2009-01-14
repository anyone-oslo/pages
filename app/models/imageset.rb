class Imageset < ActiveRecord::Base

	has_many :set_images, :order => :position, :dependent => :destroy

	#has_many   :sets,
	#           :class_name     => 'SetImage',
	#           :foreign_key    => 'image_id'
	#           :include        => [ :image ]
	
	# Reorder the set images. The argument should be an array of image ids.
	def reorder!( new_order=[] )
		i = 0; new_order.each { |id| self.set_images.find( :first, :conditions => [ "image_id = ?", id ] ).update_attribute( :position, i+=1 ) }
	end
end
