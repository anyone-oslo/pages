# encoding: utf-8

class AdminMailer < ActionMailer::Base

  def self.default_address
    "support@anyone.no"
  end

  def generic_mailer( options )
    @recipients = options[:recipients] || AdminMailer.default_address
    @from       = options[:from]       || AdminMailer.default_address
    @cc         = options[:cc]         || ""
    @bcc        = options[:bcc]        || ""
    @subject    = options[:subject]    || ""
    @body       = options[:body]       || {}
    @headers    = options[:headers]    || {}
    @charset    = options[:charset]    || "utf-8"
  end

  # Create placeholders for whichever e-mails you need to deal with.
  # Override mail elements where necessary
  #
  # def contact_us( options )
  #	 self.generic_mailer( options )
  # end

  def new_user( options=Hash.new )
    options[:subject]    = "#{options[:site_name]} has invited you to Pages"
    options[:recipients] = options[:user].email
    options[:body] = { :user => options[:user], :site_name => options[:site_name], :login_url => options[:login_url] }
    self.generic_mailer( options )
  end

  def user_changed( options=Hash.new )
    options[:subject]    = "Your Pages account on #{options[:site_name]} has been edited"
    options[:recipients] = options[:user].email
    options[:body]       = options
    self.generic_mailer( options )
  end

  def new_password( options={} )
    options[:subject]    = "Your new password on #{options[:site_name]}"
    options[:recipients] = options[:user].email
    options[:body] = { :user => options[:user], :site_name => options[:site_name], :login_url => options[:login_url] }
    self.generic_mailer( options )
  end

  def error_report(options={})
    mailer_options = {}
    short_message = options[:error_report][:message].gsub(/[\s\n]+/, ' ')[0..80]
    mailer_options[:subject]    = "[#{options[:site_name]}] " rescue "[Pages] "
    mailer_options[:subject]   += "Error: #{short_message}" rescue "Unknown error"
    mailer_options[:recipients] = "system+error@anyone.no"
    mailer_options[:body]       = options
    mailer_options[:from]       = options[:from] if options[:from] && !options[:from].empty?
    content_type "text/html"
    self.generic_mailer(mailer_options)
  end

  def comment_notification(recipients, options={})
    mailer_options = {
      :subject    => "[#{PagesCore.config(:site_name)}] New comment on #{options[:page].name.to_s}",
      :recipients => recipients,
      :from       => options[:comment].email,
      :body       => options,
    }
    self.generic_mailer(mailer_options)
  end

end
