# frozen_string_literal: true

class SessionsController < ::ApplicationController
  def create
    user = find_user(params[:username], params[:password])
    authenticate!(user) if user

    if logged_in?
      redirect_to admin_default_url
    else
      flash[:notice] = "The provided email address and password combination " \
                       "was not valid"
      redirect_to login_admin_users_url
    end
  end

  def destroy
    flash[:notice] = "You have been logged out"
    deauthenticate!
    redirect_to login_admin_users_url
  end

  protected

  def find_user(username, password)
    User.authenticate(username, password: password) if username && password
  end
end
