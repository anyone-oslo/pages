# frozen_string_literal: true

require "rails_helper"

describe Admin::OtpSecretsController do
  let(:user) { create(:user, :otp) }

  before { login(user) }

  describe "GET disable" do
    before { get :disable }

    it { is_expected.to render_template("admin/otp_secrets/disable") }

    context "when OTP is not enabled" do
      let(:user) { create(:user) }

      it { is_expected.to redirect_to(edit_admin_user_path(user)) }

      it "sets the flash" do
        expect(flash[:notice]).to eq(I18n.t("pages_core.otp.not_enabled"))
      end
    end
  end

  describe "DELETE destroy" do
    context "without a code" do
      before { delete :destroy }

      it { is_expected.to redirect_to(disable_admin_otp_secret_path) }

      it "does not disable OTP" do
        expect(user.reload.otp_enabled?).to be(true)
      end
    end

    context "with a recovery code" do
      before { delete :destroy, params: { otp: "recovery-code-1" } }

      it { is_expected.to redirect_to(edit_admin_user_path(user)) }

      it "disables OTP" do
        expect(user.reload.otp_enabled?).to be(false)
      end
    end

    context "when OTP is not enabled" do
      let(:user) { create(:user) }

      before { delete :destroy, params: { otp: "123456" } }

      it { is_expected.to redirect_to(edit_admin_user_path(user)) }

      it "sets the flash" do
        expect(flash[:notice]).to eq(I18n.t("pages_core.otp.not_enabled"))
      end
    end
  end
end
