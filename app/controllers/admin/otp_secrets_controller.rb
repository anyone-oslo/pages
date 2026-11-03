# frozen_string_literal: true

module Admin
  class OtpSecretsController < Admin::AdminController
    before_action :require_otp_disabled, only: %i[new create]
    before_action :require_otp_enabled, only: %i[disable destroy]
    before_action :find_otp_secret

    def new
      @otp_secret.generate
    end

    def create
      if @otp_secret.verify!(otp_secret_params)
        @recovery_codes = @otp_secret.generate_recovery_codes
        @otp_secret.enable!(@recovery_codes)
      else
        flash[:error] = t("pages_core.otp.invalid_code")
        redirect_to new_admin_otp_secret_path
      end
    end

    def disable; end

    def destroy
      if @otp_secret.validate_otp_or_recovery_code!(params[:otp])
        @otp_secret.disable!
        flash[:notice] = t("pages_core.otp.disabled")
        redirect_to edit_admin_user_path(current_user)
      else
        flash[:error] = t("pages_core.otp.invalid_code")
        redirect_to disable_admin_otp_secret_path
      end
    end

    private

    def find_otp_secret
      @otp_secret = OtpSecret.new(current_user)
    end

    def otp_secret_params
      params.permit(:signed_message, :otp)
    end

    def require_otp_enabled
      return if current_user.otp_enabled?

      flash[:notice] = t("pages_core.otp.not_enabled")
      redirect_to edit_admin_user_path(current_user)
    end

    def require_otp_disabled
      return unless current_user.otp_enabled?

      flash[:notice] = t("pages_core.otp.already_enabled")
      redirect_to edit_admin_user_path(current_user)
    end
  end
end
