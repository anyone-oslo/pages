# encoding: utf-8

# GenericMailer allows you to send arbitrary emails without creating templates,
# especially suited for one-offs.
#
# Usage example:
#
#  default_options = {:from => 'MyFestival <no-reply@myfestival.com>', :subject => 'Hi dear user!'}
#  registrations = Registration.find(:all, :conditions => ['country = "Norway"'])
#  registrations.each{|r| GenericMailer.deliver_mail(default_options.merge({:registration => r, :recipients => r.email, :template => 'Hi <%= @registration.name %>!'}))}

class GenericMailer < ActionMailer::Base

  def mail(options)
    # Defaults
    options = {
      :charset      => 'utf8',
      :content_type => 'text/plain'
    }.merge(options)

    # Errors
    raise "Subject required"    unless options.has_key?(:subject)
    raise "Recipients required" unless options.has_key?(:recipients)
    raise "From required"       unless options.has_key?(:from)

    # Set options
    options.each do |key, value|
      if [:subject, :recipients, :from, :cc, :bcc, :content_type, :reply_to, :headers, :sent_on].include?(key)
        self.send(key, value)
      end
    end

    # Render template
    if options[:template]
      renderer = ActionView::Base.new([], options, self)
      options[:body] = renderer.render :inline => options[:template]
    end

    raise ":body or :template required" unless options[:body]

    body options
  end

end
