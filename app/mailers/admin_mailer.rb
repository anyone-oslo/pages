# encoding: utf-8

class AdminMailer < ActionMailer::Base

  default from: Proc.new { "support@manualdesign.no" }

  def error_report(error_report, from, description)
    @error_report, @from, @description = error_report, from, description
    short_message = @error_report[:message].gsub(/[\s\n]+/, ' ')[0..80]
    mail(
      to:      'system+error@manualdesign.no',
      from:    (!@from.empty? ? @from : 'support@manualdesign.no'),
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

  def user_changed(user, login_url, updated_by)
    @user, @login_url, @updated_by = user, login_url, updated_by
    mail(
      to:      @user.email,
      subject: "Your Pages account on #{PagesCore.config(:site_name)} has been edited"
    )
  end

  def new_password(user, password, login_url)
    @user, @password, @login_url = user, password, login_url
    mail(
      to:      @user.email,
      subject: "Your new password on #{PagesCore.config(:site_name)}"
    )
  end

  def comment_notification(recipient, page, comment, url)
    @recipient, @page, @comment, @url = recipient, page, comment, url
    mail(
      to:      recipient,
      from:    @comment.email,
      subject: "[#{PagesCore.config(:site_name)}] New comment on #{@page.name.to_s}"
    )
  end

end
