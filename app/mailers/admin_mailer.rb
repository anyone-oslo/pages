# encoding: utf-8

class AdminMailer < ActionMailer::Base
  default from: proc { "\"Pages\" <support@kord.no>" }

  def error_report(error_report, from, description)
    @error_report, @from, @description = error_report, from, description
    short_message = @error_report[:message].gsub(/[\s\n]+/, " ")[0..80]
    mail(
      to:      "system+error@kord.no",
      from:    "\"Error reports\" <system+error@kord.no>",
      subject: "[#{PagesCore.config(:site_name)}] Error: #{short_message}"
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
      subject: "[#{PagesCore.config(:site_name)}] New comment on #{@page.name}"
    )
  end

  def invite(invite, url)
    @invite, @url = invite, url
    mail(
      to:      @invite.email,
      subject: "#{PagesCore.config(:site_name)} has invited you to Pages"
    )
  end
end
