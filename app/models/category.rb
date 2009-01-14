class Category < ActiveRecord::Base
	has_and_belongs_to_many :pages, :join_table => :pages_categories
	validates_presence_of :name
	acts_as_list
	
	before_save do |cat|
		cat.slug = cat.name.dup.ascii.downcase.gsub(/[^\w\s]/,'')
		cat.slug = cat.slug.split( /[^\w\d\-]+/ ).compact.join( "-" )
	end
end