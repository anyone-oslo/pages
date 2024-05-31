# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  default from: proc { "\"Pages\" <no-reply@anyone.no>" }
  layout "pages_core/mailer"

  def account_recovery(user, url)
    @user = user
    @url = url
    mail(to: @user.email,
         subject: "Recover your account on #{PagesCore.config(:site_name)}")
  end

  def invite(invite, url)
    @invite = invite
    @url = url
    mail(to: @invite.email,
         subject: "#{PagesCore.config(:site_name)} has invited you to Pages")
  end
end
