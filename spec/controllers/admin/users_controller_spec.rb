# frozen_string_literal: true

require "rails_helper"

describe Admin::UsersController do
  let(:user) { create(:user) }

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

  describe "PUT update" do
    before { login(user) }

    let(:params) { { email: "new@example.com" } }

    context "with valid params" do
      before { put :update, params: { id: user.id, user: params } }

      it { is_expected.to redirect_to(admin_users_url) }
    end

    context "with invalid params" do
      let(:params) { { email: "invalid" } }

      before { put :update, params: { id: user.id, user: params } }

      it { is_expected.to render_template("admin/users/edit") }
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

  describe "DELETE delete_image" do
    before do
      user.update(image: create(:image))
      login(user)
      delete :delete_image, params: { id: user.id }
    end

    it { is_expected.to redirect_to(edit_admin_user_url(user)) }
  end
end
