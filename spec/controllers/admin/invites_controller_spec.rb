# frozen_string_literal: true

require "rails_helper"

describe Admin::InvitesController do
  let(:user) { create(:user, :admin) }
  let(:invite) { create(:invite) }

  describe "POST create" do
    let(:hosts) { [] }

    before do
      allow(Rails.application.config).to receive(:hosts).and_return(hosts)
      allow(AdminMailer).to(
        receive(:default_url_options).and_return(host: "mail.example.com")
      )
      login(user)
      perform_enqueued_jobs do
        post :create, params: { invite: { email: "invited@example.com" } }
      end
    end

    specify do
      expect(last_email.body.encoded).to(
        include("https://mail.example.com/admin/invites/")
      )
    end

    context "when host authorization is enabled" do
      let(:hosts) { ["test.host"] }

      specify do
        expect(last_email.body.encoded).to(
          include("http://test.host/admin/invites/")
        )
      end
    end
  end

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
