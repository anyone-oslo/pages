# frozen_string_literal: true

require "rails_helper"

describe Admin::SessionsController do
  let(:user) { create(:user, :otp) }
  let(:otp) { ROTP::TOTP.new(user.otp_secret).now }

  describe "POST verify_otp" do
    context "without a pending login" do
      before { post :verify_otp, params: { otp: } }

      it { is_expected.to redirect_to(admin_login_url) }

      it "does not log in" do
        expect(session[:current_user]).to be_nil
      end
    end

    context "with a signed user id" do
      let(:signed_user_id) do
        Rails.application.message_verifier(:session)
             .generate(user.id, expires_in: 1.hour)
      end

      before { post :verify_otp, params: { otp:, signed_user_id: } }

      it { is_expected.to redirect_to(admin_login_url) }

      it "does not log in" do
        expect(session[:current_user]).to be_nil
      end
    end

    context "with a pending login" do
      before do
        post :create, params: { email: user.email, password: user.password }
        post :verify_otp, params: { otp: }
      end

      it { is_expected.to redirect_to(admin_default_url) }

      it "logs in" do
        expect(session[:current_user]).to include(id: user.id)
      end

      it "clears the pending login" do
        expect(session[:pending_otp]).to be_nil
      end
    end
  end
end
