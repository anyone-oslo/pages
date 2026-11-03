# frozen_string_literal: true

require "rails_helper"

describe "OTP rate limit" do
  let(:user) { create(:user, :otp) }
  let(:token) { user.password_reset_token }
  let(:otp) { ROTP::TOTP.new(user.otp_secret).now }

  def verify_otp(code)
    post verify_otp_admin_session_path, params: { otp: code }
  end

  def recover(code)
    put admin_account_recovery_path,
        params: { token:, otp: code,
                  user: { password: "new password",
                          password_confirmation: "new password" } }
  end

  before do
    post admin_session_path, params: { email: user.email, password: user.password }
    3.times { verify_otp("000000") }
    2.times { recover("000000") }
  end

  context "when verifying OTP on login" do
    before { verify_otp(otp) }

    it { expect(response).to redirect_to(admin_login_url) }

    it "sets the flash" do
      expect(flash[:notice]).to eq(I18n.t("pages_core.rate_limited"))
    end
  end

  context "when recovering the account" do
    before { recover(otp) }

    it { expect(response).to redirect_to(new_admin_account_recovery_url) }

    it "does not change the password" do
      expect(user.reload.authenticate("new password")).to be(false)
    end
  end
end
