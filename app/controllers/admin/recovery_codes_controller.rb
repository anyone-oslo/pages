# frozen_string_literal: true

module Admin
  class RecoveryCodesController < Admin::AdminController
    before_action :require_otp_enabled
    before_action :find_otp_secret

    def new; end

    def create
      if @otp_secret.validate_otp!(params[:otp])
        @recovery_codes = @otp_secret.regenerate_recovery_codes!
      else
        flash[:error] = t("pages_core.otp.invalid_code")
        redirect_to new_admin_recovery_codes_path
      end
    end

    private

    def find_otp_secret
      @otp_secret = OtpSecret.new(current_user)
    end

    def require_otp_enabled
      return if current_user.otp_enabled?

      flash[:notice] = t("pages_core.otp.required")
      redirect_to edit_admin_user_path(current_user)
    end
  end
end
