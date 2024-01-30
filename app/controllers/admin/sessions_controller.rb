# frozen_string_literal: true

module Admin
  class SessionsController < Admin::AdminController
    before_action :require_authentication, only: %i[destroy]
    before_action :find_user, only: %i[create]
    before_action :find_signed_user, only: %i[verify_otp]
    before_action :require_user, only: %i[create verify_otp]

    def new
      redirect_to admin_default_url if logged_in?
    end

    def create
      if @user.otp_enabled?
        @signed_user_id = message_verifier.generate(
          @user.id, expires_in: 1.hour
        )
        render template: "admin/sessions/verify_otp"
      else
        authenticate!(@user)
        redirect_to admin_default_url
      end
    end

    def destroy
      flash[:notice] = t("pages_core.logged_out")
      deauthenticate!
      redirect_to admin_login_url
    end

    def verify_otp
      @otp_secret = OtpSecret.new(@user)
      if @otp_secret.validate_otp!(params[:otp])
        authenticate!(@user)
        redirect_to admin_default_url
      else
        flash[:notice] = t("pages_core.otp.invalid_code")
        render template: "admin/sessions/verify_otp"
      end
    end

    private

    def find_signed_user
      @signed_user_id = params[:signed_user_id]
      @user = User.find(message_verifier.verify(@signed_user_id))
    end

    def find_user
      @user = User.authenticate(params[:email], password: params[:password])
    end

    def message_verifier
      Rails.application.message_verifier(:session)
    end

    def require_user
      return if @user

      flash[:notice] = t("pages_core.invalid_login")
      redirect_to admin_login_url
    end
  end
end
