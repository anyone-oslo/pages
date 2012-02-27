# encoding: utf-8

class SetImage < ActiveRecord::Base
	set_table_name  'images_imagesets'

	acts_as_list :scope => :imageset_id

	belongs_to :imageset
	belongs_to :image
end
