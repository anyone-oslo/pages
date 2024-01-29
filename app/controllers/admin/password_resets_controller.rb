# frozen_string_literal: true

module Admin
  class PasswordResetsController < Admin::AdminController
    before_action :require_authentication, except: %i[new create show update]
    before_action :find_by_token, only: %i[show update]
    before_action :require_otp, only: %i[update]

    def show; end

    def new; end

    def create
      @user = find_user_by_email(params[:email])
      if @user
        deliver_password_reset(@user)
        flash[:notice] = t("pages_core.password_reset.sent")
      else
        flash[:notice] = t("pages_core.password_reset.not_found")
      end
      redirect_to admin_login_url
    end

    def update
      if user_params[:password].present? && @user.update(user_params)
        authenticate!(@user)
        flash[:notice] = t("pages_core.password_reset.changed")
        redirect_to admin_login_url
      else
        render action: :show
      end
    end

    private

    def deliver_password_reset(user)
      AdminMailer.password_reset(
        user,
        recovery_url(user)
      ).deliver_later
    end

    def fail_reset(message)
      flash[:notice] = message
      redirect_to new_admin_password_reset_url
    end

    def find_by_token
      @token = params[:token]
      @user = User.find(message_verifier.verify(@token)[:id])
      return if @user

      fail_reset(t("pages_core.password_reset.invalid_request"))
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      fail_reset(t("pages_core.password_reset.invalid_request"))
    end

    def find_user_by_email(email)
      return unless email

      User.find_by_email(params[:email])
    end

    def message_verifier
      Rails.application.message_verifier(:password_reset)
    end

    def recovery_token(user)
      message_verifier.generate({ id: user.id }, expires_in: 24.hours)
    end

    def recovery_url(user)
      admin_password_reset_url(token: recovery_token(user))
    end

    def require_otp
      return if valid_otp(@user, params[:otp])

      flash.now[:notice] = t("pages_core.otp.invalid_code")
      render action: :show
    end

    def user_params
      params.require(:user).permit(:password, :confirm_password)
    end

    def valid_otp(user, otp)
      return true unless user.otp_enabled?

      OtpSecret.new(user).validate_otp!(otp)
    end
  end
end
