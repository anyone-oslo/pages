# encoding: utf-8

class MailSubscriber < ActiveRecord::Base
  validates_presence_of   :email
  validates_uniqueness_of :email, :scope => :group
  validates_format_of     :email,    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => 'is not a valid email address'

  class << self

    # Find all group names
    def groups
      self.find_by_sql( "SELECT DISTINCT m.group FROM mail_subscribers m" ).mapped.group
    end

    def subscribe(email, group=nil)
      existing = MailSubscriber.find(:all, :conditions => ['email = ?', email])
      if existing.length > 0
        existing.each{|ms| ms.update_attribute(:unsubscribed, false)}
      end
      create_opts = (group) ? {:email => email, :group => group} : {:email => email}
      if MailSubscriber.exists?(create_opts)
        MailSubscriber.find(:first, :conditions => create_opts)
      else
        MailSubscriber.create(create_opts)
      end
    end

    def unsubscribe(email)
      existing = MailSubscriber.find(:all, :conditions => ['email = ?', email])
      if existing.length > 0
        existing.each{|ms| ms.update_attribute(:unsubscribed, true)}
      else
        MailSubscriber.create(:email => email, :unsubscribed => true)
      end
    end

    def unsubscribed_emails
      self.find_by_sql('SELECT DISTINCT(email) FROM mail_subscribers WHERE unsubscribed = 1').map{|ms| ms.email }
    end

  end

end
