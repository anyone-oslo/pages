class PageComment < ActiveRecord::Base
	
	belongs_to :page, :counter_cache => :comments_count
	attr_accessor :invalid_captcha
	
	def valid_captcha?
		(self.invalid_captcha) ? false : true
	end
	
	after_create do |page_comment|
		if page_comment.page
			page_comment.page.update_attribute(:last_comment_at, page_comment.created_at)
		end
	end
	
end
