# frozen_string_literal: true

require "rails_helper"

describe Admin::UsersController do
  let(:user) { create(:user, :admin) }
  let(:editor) { create(:user).tap { |u| u.update!(role_names: %w[pages]) } }

  describe "GET index" do
    before do
      login(user)
      get :index
    end

    it { is_expected.to render_template("admin/users/index") }

    it "assigns to users" do
      expect(assigns(:users)).to be_an(ActiveRecord::Relation)
    end

    it "assigns to invites" do
      expect(assigns(:invites)).to be_an(ActiveRecord::Relation)
    end
  end

  describe "GET deactivated" do
    before do
      login(user)
      get :deactivated
    end

    it { is_expected.to render_template("admin/users/deactivated") }

    it "assigns to users" do
      expect(assigns(:users)).to be_an(ActiveRecord::Relation)
    end

    it "assigns to invites" do
      expect(assigns(:invites)).to eq([])
    end
  end

  describe "GET deactivated without the users role" do
    before do
      login(editor)
      get :deactivated
    end

    it { is_expected.to render_template("admin/users/deactivated") }
  end

  describe "GET deactivated when not logged in" do
    before do
      user
      get :deactivated
    end

    it { is_expected.to redirect_to(admin_login_url) }
  end

  describe "GET new" do
    context "with no users" do
      before { get :new }

      it { is_expected.to render_template("admin/users/new") }

      it "assigns the user" do
        expect(assigns(:user)).to be_a(User)
      end
    end

    context "with users" do
      before do
        create(:user)
        get :new
      end

      it { is_expected.to redirect_to(admin_users_url) }
    end
  end

  describe "POST create" do
    let(:params) { attributes_for(:user) }

    context "with invalid params" do
      let(:params) { { name: "foo" } }

      before { post :create, params: { user: params } }

      it { is_expected.to render_template("admin/users/new") }

      it "assigns the user" do
        expect(assigns(:user)).to be_a(User)
      end
    end

    context "with valid params" do
      before { post :create, params: { user: params } }

      it { is_expected.to redirect_to(admin_default_url) }

      it "authenticates the user" do
        expect(assigns(:current_user)).to eq(User.last)
      end
    end

    context "with users" do
      before do
        create(:user)
        post :create, params: { user: params }
      end

      it { is_expected.to redirect_to(admin_users_url) }
    end
  end

  describe "GET show" do
    before do
      login(user)
      get :show, params: { id: user.id }
    end

    it { is_expected.to render_template("admin/users/show") }

    it "assigns the user" do
      expect(assigns(:user)).to be_a(User)
    end
  end

  describe "GET show without the users role" do
    before { login(editor) }

    it "allows showing themselves" do
      get :show, params: { id: editor.id }
      expect(response).to render_template("admin/users/show")
    end

    it "allows showing other users" do
      get :show, params: { id: user.id }
      expect(response).to render_template("admin/users/show")
    end
  end

  describe "GET edit" do
    before do
      login(user)
      get :edit, params: { id: user.id }
    end

    it { is_expected.to render_template("admin/users/edit") }

    it "assigns the user" do
      expect(assigns(:user)).to be_a(User)
    end
  end

  describe "GET edit without the users role" do
    before { login(editor) }

    it "allows editing themselves" do
      get :edit, params: { id: editor.id }
      expect(response).to render_template("admin/users/edit")
    end

    it "does not allow editing other users" do
      expect { get :edit, params: { id: user.id } }
        .to raise_error(PagesCore::NotAuthorized)
    end
  end

  describe "PUT update" do
    let(:target) { user }
    let(:params) do
      { email: "new@example.com", current_password: user.password }
    end

    before do
      login(user)
      put :update, params: { id: target.id, user: params }
    end

    context "with valid params" do
      it { is_expected.to redirect_to(admin_users_url) }

      it "changes the email" do
        expect(target.reload.email).to eq("new@example.com")
      end
    end

    context "with invalid params" do
      let(:params) { { email: "invalid", current_password: user.password } }

      it { is_expected.to render_template("admin/users/edit") }
    end

    context "when changing the email without the current password" do
      let(:params) { { email: "new@example.com" } }

      it { is_expected.to render_template("admin/users/edit") }

      it "does not change the email" do
        expect(user.reload.email).not_to eq("new@example.com")
      end
    end

    context "when changing the email with the wrong password" do
      let(:params) { { email: "new@example.com", current_password: "wrong" } }

      it { is_expected.to render_template("admin/users/edit") }

      it "adds an error" do
        expect(assigns(:user).errors[:current_password]).to be_present
      end
    end

    context "when changing the password without the current password" do
      let(:params) { { password: "new password", password_confirmation: "new password" } }

      it { is_expected.to render_template("admin/users/edit") }

      it "does not change the password" do
        expect(user.reload.authenticate("new password")).to be_falsey
      end
    end

    context "when changing the password with the current password" do
      let(:params) do
        { password: "new password",
          password_confirmation: "new password",
          current_password: user.password }
      end

      it "changes the password" do
        expect(user.reload.authenticate("new password")).to eq(user)
      end
    end

    context "when changing the name without the current password" do
      let(:params) { { name: "New name" } }

      it { is_expected.to redirect_to(admin_users_url) }
    end

    context "when an admin changes another user's email" do
      let(:user) { create(:user, :admin) }
      let(:target) { create(:user) }
      let(:params) { { email: "new@example.com" } }

      it "changes the email" do
        expect(target.reload.email).to eq("new@example.com")
      end
    end
  end

  describe "PUT update without the users role" do
    let(:params) { { email: "new@example.com", current_password: editor.password } }

    before { login(editor) }

    it "allows updating themselves" do
      put :update, params: { id: editor.id, user: params }
      expect(editor.reload.email).to eq("new@example.com")
    end

    it "does not allow updating other users" do
      expect { put :update, params: { id: user.id, user: params } }
        .to raise_error(PagesCore::NotAuthorized)
    end

    it "does not change other users", :aggregate_failures do
      expect do
        expect { put :update, params: { id: user.id, user: params } }
          .to raise_error(PagesCore::NotAuthorized)
      end.not_to(change { user.reload.email })
    end

    it "does not grant themselves roles" do
      put :update, params: { id: editor.id, user: params.merge(role_names: ["users"]) }
      expect(editor.reload.role?(:users)).to be(false)
    end
  end

  describe "DELETE destroy" do
    before do
      login(user)
      delete :destroy, params: { id: target.id }
    end

    let!(:target) { create(:user) }

    it { is_expected.to redirect_to(admin_users_url) }

    it "deletes the user" do
      expect(User.all).to contain_exactly(user)
    end
  end

  describe "DELETE destroy without the users role" do
    before { login(editor) }

    it "does not allow deleting other users" do
      expect { delete :destroy, params: { id: user.id } }
        .to raise_error(PagesCore::NotAuthorized)
    end

    it "does not delete the user", :aggregate_failures do
      expect do
        expect { delete :destroy, params: { id: user.id } }
          .to raise_error(PagesCore::NotAuthorized)
      end.not_to(change { User.exists?(user.id) })
    end
  end

  describe "DELETE destroy_sessions" do
    let(:target) { user }

    before do
      login(user)
      delete :destroy_sessions, params: { id: target.id }
    end

    it { is_expected.to redirect_to(edit_admin_user_url(target)) }

    it "changes the session token" do
      expect { target.reload }.to change(target, :session_token)
    end

    it "keeps the current session" do
      expect(session[:current_user][:token]).to eq(target.reload.session_token)
    end

    context "when the user has the users role" do
      let(:user) { create(:user, :admin) }
      let(:target) { create(:user) }

      it "changes the target's session token" do
        expect { target.reload }.to change(target, :session_token)
      end
    end

    context "when the target has invalid data" do
      let(:user) { create(:user, :admin) }
      let(:target) do
        create(:user).tap do |u|
          u.name = ""
          u.save(validate: false)
        end
      end

      it "changes the target's session token" do
        expect { target.reload }.to change(target, :session_token)
      end
    end
  end

  describe "DELETE destroy_sessions for another user" do
    let!(:target) { create(:user) }

    before { login(create(:user, role_names: %w[pages])) }

    it "is not authorized" do
      expect do
        delete :destroy_sessions, params: { id: target.id }
      end.to raise_error(PagesCore::NotAuthorized)
    end
  end

  describe "DELETE delete_image" do
    before do
      user.update(image: create(:image))
      login(user)
      delete :delete_image, params: { id: user.id }
    end

    it { is_expected.to redirect_to(edit_admin_user_url(user)) }
  end

  describe "DELETE delete_image without the users role" do
    before do
      user.update(image: create(:image))
      editor.update(image: create(:image))
      login(editor)
    end

    it "allows deleting their own image" do
      delete :delete_image, params: { id: editor.id }
      expect(response).to redirect_to(edit_admin_user_url(editor))
    end

    it "does not allow deleting other users' images" do
      expect { delete :delete_image, params: { id: user.id } }
        .to raise_error(PagesCore::NotAuthorized)
    end
  end
end
