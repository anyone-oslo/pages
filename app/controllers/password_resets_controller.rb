# encoding: utf-8

class PasswordResetsController < ApplicationController
  def create
    if params[:username] && user = User.find_by_username_or_email(params[:username])
      new_password = user.generate_new_password
      user.save

      AdminMailer.new_password(user, new_password, admin_default_url).deliver
      flash[:notice] = "A new password has been sent to your email address"
    else
      flash[:notice] = "Could not find your user account"
    end
    redirect_to login_url
  end

  protected

  def login_url
    # TODO: Validate URL
    params[:login_url] || login_admin_users_url
  end
end