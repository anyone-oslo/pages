# encoding: utf-8

class AdminMailer < ActionMailer::Base
  default from: proc { "\"Pages\" <support@kord.no>" }

  def error_report(error_report, from, description)
    @error_report = error_report
    @from = from
    @description = description
    short_message = @error_report[:message].gsub(/[\s\n]+/, " ")[0..80]
    mail(
      to:      "system+error@kord.no",
      from:    "\"Error reports\" <system+error@kord.no>",
      subject: "[#{PagesCore.config(:site_name)}] Error: #{short_message}"
    )
  end

  def password_reset(user, url)
    @user = user
    @url = url
    mail(
      to: @user.email,
      subject: "Reset your password on #{PagesCore.config(:site_name)}"
    )
  end

  def invite(invite, url)
    @invite = invite
    @url = url
    mail(
      to:      @invite.email,
      subject: "#{PagesCore.config(:site_name)} has invited you to Pages"
    )
  end
end
