# frozen_string_literal: true

require "rails_helper"

describe Admin::InvitesController do
  let(:invite) { create(:invite) }

  describe "GET show" do
    before { get :show, params: { id: invite.id, token: } }

    context "with a valid token" do
      let(:token) { invite.token }

      it { is_expected.to render_template("admin/invites/show") }
    end

    context "with an invalid token" do
      let(:token) { "invalid" }

      it { is_expected.to redirect_to(admin_login_url) }

      it "sets the flash" do
        expect(flash[:notice]).to eq(I18n.t("pages_core.invite_expired"))
      end
    end
  end

  describe "POST accept" do
    let(:user_params) do
      { name: "Invited User", email: invite.email,
        password: "Correct Horse Battery Staple",
        password_confirmation: "Correct Horse Battery Staple" }
    end

    before { post :accept, params: { id: invite.id, token:, user: user_params } }

    context "with a valid token" do
      let(:token) { invite.token }

      it { is_expected.to redirect_to(admin_default_url) }
    end

    context "with a non-string token" do
      let(:token) { ["a"] }

      it { is_expected.to redirect_to(admin_login_url) }

      it "sets the flash" do
        expect(flash[:notice]).to eq(I18n.t("pages_core.invite_expired"))
      end
    end
  end
end
