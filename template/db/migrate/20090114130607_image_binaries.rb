class ImageBinaries < ActiveRecord::Migration
	def self.up
		add_column :images, :binary_id, :integer
		Image.find( :all ).each do |image|
			binary = Binary.create(:data => image[:data])
			image.update_attribute(:binary_id, binary.id)
		end
		remove_column :images, :data
	end

	def self.down
		add_column    :images, :data, :binary, :limit => 100.megabytes
		Binary.find( :all, :conditions => [ "linkable_type = 'Image'" ] ).each do |b|
			#b.linkable[:data] = b.data
			#b.linkable.save
			b.destroy
		end
		remove_column :images, :binary_id
	end
end
