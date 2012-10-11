# encoding: utf-8

class SmsSubscriber < ActiveRecord::Base
	validates_presence_of   :msisdn
	validates_uniqueness_of :msisdn, :scope => :group

	class << self

		def groups
      self.find_by_sql("SELECT DISTINCT m.group FROM sms_subscribers m").map{|s| s.group}
		end

	end

end
