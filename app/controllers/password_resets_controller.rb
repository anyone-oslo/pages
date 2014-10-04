# encoding: utf-8

class PasswordResetsController < Admin::AdminController
  before_action :find_password_reset_token, only: [:show, :update]
  before_action :check_for_expired_token, only: [:show, :update]
  before_action :require_authentication, except: [:create, :show, :update]

  layout 'admin'

  def create
    if params[:username] && @user = User.find_by_username_or_email(params[:username])
      @password_reset_token = @user.password_reset_tokens.create
      AdminMailer.password_reset(
        @user,
        password_reset_with_token_url(
          @password_reset_token, @password_reset_token.token
        )
      ).deliver
      flash[:notice] = "An email with further instructions has been sent"
    else
      flash[:notice] = "Couldn't find a user with that email address"
    end
    redirect_to login_url
  end

  def show
    @user = @password_reset_token.user
  end

  def update
    @user = @password_reset_token.user
    if !user_params[:password].blank? && @user.update(user_params)
      @password_reset_token.destroy
      authenticate!(@user)
      flash[:notice] = "Your password has been changed"
      redirect_to login_url
    else
      render action: :show
    end
  end

  private

  def login_url
    # TODO: Validate URL
    params[:login_url] || login_admin_users_url
  end

  def user_params
    params.require(:user).permit(:password, :confirm_password)
  end

  def find_password_reset_token
    begin
      @password_reset_token = PasswordResetToken.find(params[:id])
    rescue ActiveRecord::RecordNotFound
    end
    unless @password_reset_token && @password_reset_token.token == params[:token]
      flash[:notice] = "Invalid password reset request"
      redirect_to login_url and return
    end
  end

  def check_for_expired_token
    if @password_reset_token.expired?
      @password_reset_token.destroy
      flash[:notice] = "Your password reset link has expired"
      redirect_to login_url and return
    end
  end
end