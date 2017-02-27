# encoding: utf-8

class SessionsController < ::ApplicationController
  def create
    if params[:username] && params[:password]
      if user = User.authenticate(params[:username], password: params[:password])
        authenticate!(user)
      end
    end

    if logged_in?
      redirect_to success_url
    else
      flash[:notice] = "The provided email address and password combination was not valid"
      redirect_to login_url
    end
  end

  def destroy
    flash[:notice] = "You have been logged out"
    deauthenticate!
    redirect_to login_url
  end

  protected

  def success_url
    # TODO: Validate URL
    params[:success_url] || admin_default_url
  end

  def login_url
    # TODO: Validate URL
    params[:login_url] || login_admin_users_url
  end
end
