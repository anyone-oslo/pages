# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  default from: proc { "\"Pages\" <support@anyone.no>" }

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
      to: @invite.email,
      subject: "#{PagesCore.config(:site_name)} has invited you to Pages"
    )
  end
end
