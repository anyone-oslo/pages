# frozen_string_literal: true

module Admin
  class PasswordResetsController < Admin::AdminController
    before_action :find_password_reset_token, only: %i[show update]
    before_action :check_for_expired_token, only: %i[show update]
    before_action :require_authentication, except: %i[create show update]

    layout "admin"

    def show
      @user = @password_reset_token.user
    end

    def create
      @user = find_user_by_email(params[:email])
      if @user
        @password_reset_token = @user.password_reset_tokens.create
        deliver_password_reset(@user, @password_reset_token)
        flash[:notice] = t("pages_core.password_reset.sent")
      else
        flash[:notice] = t("pages_core.password_reset.not_found")
      end
      redirect_to admin_login_url
    end

    def update
      @user = @password_reset_token.user
      if !valid_otp(@user, params[:otp])
        flash.now[:notice] = t("pages_core.otp.invalid_code")
        render action: :show
      elsif user_params[:password].present? && @user.update(user_params)
        @password_reset_token.destroy
        authenticate!(@user)
        flash[:notice] = t("pages_core.password_reset.changed")
        redirect_to admin_login_url
      else
        render action: :show
      end
    end

    private

    def deliver_password_reset(user, password_reset)
      AdminMailer.password_reset(
        user,
        admin_password_reset_with_token_url(
          password_reset, password_reset.token
        )
      ).deliver_later
    end

    def find_user_by_email(email)
      return unless email

      User.find_by_email(params[:email])
    end

    def user_params
      params.require(:user).permit(:password, :confirm_password)
    end

    def valid_token?(reset)
      reset && secure_compare(reset.token, params[:token])
    end

    def find_password_reset_token
      @password_reset_token = begin
        PasswordResetToken.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        nil
      end

      return if valid_token?(@password_reset_token)

      flash[:notice] = t("pages_core.password_reset.invalid_request")
      redirect_to(admin_login_url)
    end

    def check_for_expired_token
      return unless @password_reset_token.expired?

      @password_reset_token.destroy
      flash[:notice] = t("pages_core.password_reset.expired")
      redirect_to(admin_login_url)
    end

    def valid_otp(user, otp)
      return true unless user.otp_enabled?

      OtpSecret.new(user).validate_otp!(otp)
    end
  end
end
