# frozen_string_literal: true

require "rails_helper"

describe Admin::InvitesController do
  let(:user) { create(:user, :admin) }

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
    let(:invite) { create(:invite) }

    let(:token) { invite.token }

    before do
      create(:user)
      get :show, params: { id: invite.id, token: }
    end

    it { is_expected.to render_template("admin/invites/show") }

    context "with an invalid token" do
      let(:token) { "invalid" }

      it { is_expected.to redirect_to(admin_login_url) }

      it "sets the flash" do
        expect(flash[:notice]).to eq(I18n.t("pages_core.invite_expired"))
      end
    end

    context "when the invite has expired" do
      let(:invite) { create(:invite, sent_at: 15.days.ago) }

      it { is_expected.to redirect_to(admin_login_url) }

      it "sets the flash" do
        expect(flash[:notice]).to eq(I18n.t("pages_core.invite_expired"))
      end
    end

    context "when the inviter no longer has the users role" do
      let(:invite) do
        create(:invite, user: create(:user, role_names: %w[pages]))
      end

      it { is_expected.to redirect_to(admin_login_url) }
    end
  end

  describe "POST accept" do
    let(:invite) do
      create(:invite, email: "invited@example.com", role_names: %w[users])
    end
    let(:token) { invite.token }
    let(:params) do
      { id: invite.id,
        token:,
        user: { name: "Invited",
                email: "other@example.com",
                password: "Correct Horse Battery Staple",
                password_confirmation: "Correct Horse Battery Staple" } }
    end

    before do
      create(:user)
      post :accept, params:
    end

    it { is_expected.to redirect_to(admin_default_url) }

    it "uses the email from the invite" do
      expect(User.last.email).to eq("invited@example.com")
    end

    context "with a non-string token" do
      let(:token) { ["a"] }

      it { is_expected.to redirect_to(admin_login_url) }

      it "sets the flash" do
        expect(flash[:notice]).to eq(I18n.t("pages_core.invite_expired"))
      end
    end

    context "when the inviter is deactivated" do
      let(:invite) do
        create(:invite, user: create(:user, :admin, activated: false))
      end

      it { is_expected.to redirect_to(admin_login_url) }

      it "does not create a user" do
        expect(User.find_by(email: invite.email)).to be_nil
      end
    end

    context "when the invite has expired" do
      let(:invite) { create(:invite, sent_at: 15.days.ago) }

      it "does not create a user" do
        expect(User.find_by(email: invite.email)).to be_nil
      end
    end
  end

  describe "POST accept rate limit" do
    let!(:invite) { create(:invite) }
    let(:user_params) do
      { name: "New User", email: invite.email,
        password: "Correct Horse Battery Staple",
        password_confirmation: "Correct Horse Battery Staple" }
    end

    context "when the limit is reached" do
      before do
        10.times do
          post :accept, params: { id: invite.id, token: invite.token,
                                  user: { name: "" } }
        end
      end

      it "does not create a user" do
        expect do
          post :accept, params: { id: invite.id, token: invite.token,
                                  user: user_params }
        end.not_to change(User, :count)
      end

      it "redirects to the login page" do
        post :accept, params: { id: invite.id, token: invite.token,
                                user: user_params }
        expect(response).to redirect_to(admin_login_url)
      end

      it "sets the flash" do
        post :accept, params: { id: invite.id, token: invite.token,
                                user: user_params }
        expect(flash[:notice]).to eq(I18n.t("pages_core.rate_limited"))
      end
    end

    context "when the limit is reached for another invite" do
      before do
        other = create(:invite)
        10.times do
          post :accept, params: { id: other.id, token: other.token,
                                  user: { name: "" } }
        end
      end

      it "creates a user" do
        expect do
          post :accept, params: { id: invite.id, token: invite.token,
                                  user: user_params }
        end.to change(User, :count).by(1)
      end
    end
  end
end
