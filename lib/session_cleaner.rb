class SessionCleaner
	def self.remove_stale_sessions
		CGI::Session::ActiveRecordStore::Session.destroy_all( ['updated_at <?', 48.hours.ago] ) 
	end
end