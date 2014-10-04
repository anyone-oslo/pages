# encoding: utf-8

class AdminMailer < ActionMailer::Base
  before_action :default_headers
  default from: Proc.new { "\"Pages\" <support@manualdesign.no>" }

  def error_report(error_report, from, description)
    @error_report, @from, @description = error_report, from, description
    short_message = @error_report[:message].gsub(/[\s\n]+/, ' ')[0..80]
    mail(
      to:      'system+error@manualdesign.no',
      from:    "\"Error reports\" <system+error@manualdesign.no>",
      subject: "[#{PagesCore.config(:site_name)}] Error: #{short_message}"
    )
  end

  def new_user(user, login_url)
    @user, @login_url = user, login_url
    mail(
      to:      @user.email,
      subject: "#{PagesCore.config(:site_name)} has invited you to Pages"
    )
  end

  def password_reset(user, url)
    @user, @url = user, url
    mail(
      to: @user.email,
      subject: "Reset your password on #{PagesCore.config(:site_name)}"
    )
  end

  def comment_notification(recipient, page, comment, url)
    @recipient, @page, @comment, @url = recipient, page, comment, url
    mail(
      to:      recipient,
      subject: "[#{PagesCore.config(:site_name)}] New comment on #{@page.name.to_s}"
    )
  end

  private

  def default_headers
    headers("X-MC-Subaccount" => "pages")
  end
end
