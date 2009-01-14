class Event < ActiveRecord::Base
	
	has_many :registrations
	has_many :venues
	
	def to_s
		self.name
	end
	
end
