# frozen_string_literal: true

require "rails_helper"

describe Admin::SessionsController do
  let(:user) { create(:user, :otp) }
  let(:otp) { ROTP::TOTP.new(user.otp_secret).now }

  describe "POST create" do
    context "with an unknown email" do
      before do
        allow(BCrypt::Password).to receive(:create).and_call_original
        post :create, params: { email: "none@example.com", password: "password" }
      end

      it { is_expected.to redirect_to(admin_login_url) }

      it "hashes the password" do
        expect(BCrypt::Password).to have_received(:create)
      end
    end
  end

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

  describe "POST create rate limit" do
    let(:user) { create(:user) }
    let(:params) { { email: user.email, password: user.password } }

    context "when the limit is reached" do
      before do
        10.times do
          post :create, params: { email: " #{user.email.upcase} ",
                                  password: "wrong" }
        end
        post :create, params:
      end

      it { is_expected.to redirect_to(admin_login_url) }

      it "does not log in" do
        expect(session[:current_user]).to be_nil
      end

      it "sets the flash" do
        expect(flash[:notice]).to eq(I18n.t("pages_core.rate_limited"))
      end
    end

    context "when the window has passed" do
      before do
        10.times do
          post :create, params: { email: user.email, password: "wrong" }
        end
        travel_to(6.minutes.from_now) { post :create, params: }
      end

      it "logs in" do
        expect(session[:current_user]).to include(id: user.id)
      end
    end

    context "when email is an array" do
      before do
        post :create, params: { email: [user.email, "x1@example.com"],
                                password: user.password }
      end

      it { is_expected.to redirect_to(admin_login_url) }

      it "does not log in" do
        expect(session[:current_user]).to be_nil
      end

      it "sets the flash" do
        expect(flash[:notice]).to eq(I18n.t("pages_core.invalid_login"))
      end
    end

    context "when the limit is reached for another email" do
      before do
        10.times do
          post :create, params: { email: "other@example.com",
                                  password: "wrong" }
        end
        post :create, params:
      end

      it "logs in" do
        expect(session[:current_user]).to include(id: user.id)
      end
    end
  end

  describe "POST verify_otp rate limit" do
    before do
      post :create, params: { email: user.email, password: user.password }
    end

    context "when the limit is reached" do
      before do
        5.times { post :verify_otp, params: { otp: "000000" } }
        post :verify_otp, params: { otp: }
      end

      it { is_expected.to redirect_to(admin_login_url) }

      it "does not log in" do
        expect(session[:current_user]).to be_nil
      end

      it "sets the flash" do
        expect(flash[:notice]).to eq(I18n.t("pages_core.rate_limited"))
      end
    end

    context "when below the limit" do
      before do
        4.times { post :verify_otp, params: { otp: "000000" } }
        post :verify_otp, params: { otp: }
      end

      it "logs in" do
        expect(session[:current_user]).to include(id: user.id)
      end
    end
  end
end
