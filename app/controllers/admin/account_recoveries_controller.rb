# frozen_string_literal: true

module Admin
  class AccountRecoveriesController < Admin::AdminController
    before_action :require_authentication, except: %i[new create show update]
    before_action :find_by_token, only: %i[show update]
    around_action :validate_otp, only: %i[update]

    def show; end

    def new; end

    def create
      @user = User.find_by(email: params[:email])
      if @user
        deliver_account_recovery(@user)
        flash[:notice] = t("pages_core.account_recovery.sent")
      else
        flash[:notice] = t("pages_core.account_recovery.not_found")
      end
      redirect_to admin_login_url
    end

    def update
      if user_params[:password].present? && @user.update(user_params)
        authenticate!(@user)
        flash[:notice] = t("pages_core.account_recovery.changed")
        redirect_to admin_login_url
      else
        render action: :show
      end
    end

    private

    def deliver_account_recovery(user)
      AdminMailer.account_recovery(
        user,
        admin_account_recovery_with_token_url(recovery_token(user))
      ).deliver_later
    end

    def fail_recovery(message)
      flash[:notice] = message
      redirect_to new_admin_account_recovery_url
    end

    def find_by_token
      @token = params[:token]
      @user = User.find(message_verifier.verify(@token)[:id])
      return if @user

      fail_recovery(t("pages_core.account_recovery.invalid_request"))
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      fail_recovery(t("pages_core.account_recovery.invalid_request"))
    end

    def message_verifier
      Rails.application.message_verifier(:account_recovery)
    end

    def recovery_token(user)
      message_verifier.generate({ id: user.id }, expires_in: 24.hours)
    end

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def validate_otp
      User.transaction do
        if valid_otp(@user, params[:otp])
          yield
        else
          flash.now[:notice] = t("pages_core.otp.invalid_code")
          render action: :show
        end
      end
    end

    def valid_otp(user, otp)
      return true unless user.otp_enabled?

      OtpSecret.new(user).validate_otp_or_recovery_code!(otp)
    end
  end
end
