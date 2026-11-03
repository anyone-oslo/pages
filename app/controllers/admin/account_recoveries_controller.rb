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
      deliver_account_recovery(@user) if @user&.can_login?
      flash[:notice] = t("pages_core.account_recovery.sent")
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
        admin_account_recovery_with_token_url(
          user.password_reset_token, **trusted_url_options
        )
      ).deliver_later
    end

    def fail_recovery(message)
      flash[:notice] = message
      redirect_to new_admin_account_recovery_url
    end

    def find_by_token
      @token = params[:token]
      @user = User.find_by_token_for(:password_reset, @token)
      return fail_recovery(t("pages_core.account_recovery.invalid_request")) unless @user

      raise PagesCore::Authentication::LoginRefused unless @user.can_login?
    end

    def user_params
      params.expect(user: %i[password password_confirmation])
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
