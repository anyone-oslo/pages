class Category < ActiveRecord::Base
	has_and_belongs_to_many :pages, :join_table => :pages_categories
	validates_presence_of :name
	acts_as_list
	
	before_save do |cat|
		cat.slug = cat.name.dup.convert_to_ascii.downcase.gsub(/[^\w\s]/,'')
		cat.slug = cat.slug.split( /[^\w\d\-]+/ ).compact.join( "-" )
	end

	after_save do |cat|
		cat.pages.each do |page|
			page.update_attribute(:delta, true)
		end
	end
end