class PageComment < ActiveRecord::Base
	
	belongs_to :page
	attr_accessor :invalid_captcha
	
	def valid_captcha?
		(self.invalid_captcha) ? false : true
	end
	
end
