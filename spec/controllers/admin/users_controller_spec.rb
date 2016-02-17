require "rails_helper"

describe Admin::UsersController, type: :controller do
  #let(:user) { create(:user).tap { |u| u.roles.create(name: "users") } }
  let(:user) { create(:user) }

  describe "GET index" do
    before { login(user) }
    before { get :index }

    it { is_expected.to render_template("admin/users/index") }

    it "should assign to users" do
      expect(assigns(:users)).to be_an(ActiveRecord::Relation)
    end

    it "should assign to invites" do
      expect(assigns(:invites)).to be_an(ActiveRecord::Relation)
    end
  end

  describe "GET deactivated" do
    before { login(user) }
    before { get :deactivated }

    it { is_expected.to render_template("admin/users/deactivated") }

    it "should assign to users" do
      expect(assigns(:users)).to be_an(ActiveRecord::Relation)
    end

    it "should assign to invites" do
      expect(assigns(:invites)).to eq([])
    end
  end

  describe "GET login" do
    context "when not logged in" do
      before { get :login }
      it { is_expected.to render_template("admin/users/login") }
    end

    context "when logged in" do
      before { login(user) }
      before { get :login }

      it { is_expected.to redirect_to(admin_default_url) }
    end
  end

  describe "GET new" do
    context "with no users" do
      before { get :new }

      it { is_expected.to render_template("admin/users/new") }

      it "should assign the user" do
        expect(assigns(:user)).to be_a(User)
      end
    end

    context "with users" do
      let!(:user) { create(:user) }
      before { get :new }
      it { is_expected.to redirect_to(admin_users_url) }
    end
  end

  describe "POST create" do
    let(:params) { attributes_for(:user) }

    context "with invalid params" do
      let(:params) { { name: "foo" } }
      before { post :create, user: params }
      it { is_expected.to render_template("admin/users/new") }

      it "should assign the user" do
        expect(assigns(:user)).to be_a(User)
      end
    end

    context "with valid params" do
      before { post :create, user: params }
      it { is_expected.to redirect_to(admin_default_url) }

      it "should authenticate the user" do
        expect(session[:current_user_id]).to eq(User.last.id)
      end
    end

    context "with users" do
      let!(:user) { create(:user) }
      before { post :create, user: params }
      it { is_expected.to redirect_to(admin_users_url) }
    end
  end

  describe "GET show" do
    before { login(user) }
    before { get :show, id: user.id }

    it { is_expected.to render_template("admin/users/show") }

    it "should assign the user" do
      expect(assigns(:user)).to be_a(User)
    end
  end

  describe "GET edit" do
    before { login(user) }
    before { get :edit, id: user.id }

    it { is_expected.to render_template("admin/users/edit") }

    it "should assign the user" do
      expect(assigns(:user)).to be_a(User)
    end
  end

  describe "PUT update" do
    before { login(user) }
    let(:params) { { email: "new@example.com" } }

    context "with valid params" do
      before { put :update, id: user.id, user: params }
      it { is_expected.to redirect_to(admin_users_url) }
    end

    context "with invalid params" do
      let(:params) { { email: "invalid" } }
      before { put :update, id: user.id, user: params }
      it { is_expected.to render_template("admin/users/edit") }
    end
  end

  describe "DELETE destroy" do
    before { login(user) }
    let!(:target) { create(:user) }

    before { delete :destroy, id: target.id }

    it { is_expected.to redirect_to(admin_users_url) }

    it "should delete the user" do
      expect(User.all).to match_array([user])
    end
  end

  describe "DELETE delete_image" do
    before do
      user.update(image: create(:image))
      login(user)
      delete :delete_image, id: user.id
    end

    it { is_expected.to redirect_to(edit_admin_user_url(user)) }
  end
end
