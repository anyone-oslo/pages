# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    user = find_user(params[:email], params[:password])
    authenticate!(user) if user

    if logged_in?
      redirect_to admin_default_url
    else
      flash[:notice] = t("pages_core.invalid_login")
      redirect_to login_admin_users_url
    end
  end

  def destroy
    flash[:notice] = t("pages_core.logged_out")
    deauthenticate!
    redirect_to login_admin_users_url
  end

  protected

  def find_user(email, password)
    User.authenticate(email, password: password) if email && password
  end
end
