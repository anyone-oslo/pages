require "digest/sha1"

class UserLogin < ActiveRecord::Base

	belongs_to :user
	
	before_create :create_token
	
	def create_token
		self.token ||= Digest::SHA1.hexdigest( Time.now.to_s + Time.now.to_s )
	end
	
end