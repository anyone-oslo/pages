class MailSubscriber < ActiveRecord::Base
	validates_presence_of   :email
	validates_uniqueness_of :email, :scope => :group
	validates_format_of     :email,    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => 'is not a valid email address'
	
	class << self
		
		def groups
			self.find_by_sql( "SELECT DISTINCT m.group FROM mail_subscribers m" ).mapped.group
		end
		
	end
	
end
