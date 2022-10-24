# frozen_string_literal: true

module Admin
  class UsersController < Admin::AdminController
    before_action :require_authentication, except: %i[new create login]
    before_action :require_no_users, only: %i[new create]
    before_action(
      :find_user,
      only: %i[edit update show destroy delete_image]
    )

    def index
      @users = User.activated
      @invites = Invite.all.order("created_at DESC")
    end

    def deactivated
      @users = User.deactivated
      @invites = []
    end

    def login
      return unless logged_in?

      redirect_to admin_default_url
    end

    def show; end

    def new
      @user = User.new
    end

    def edit; end

    def create
      @user = PagesCore::CreateUserService.call(user_params)
      if @user.valid?
        authenticate!(@user)
        redirect_to admin_default_url
      else
        render action: :new
      end
    end

    def update
      if @user.update(user_params_with_roles)
        flash[:notice] = "Your changed to #{@user.name} were saved."
        redirect_to admin_users_url
      else
        flash.now[:error] = "There were problems saving your changes."
        render action: :edit
      end
    end

    def destroy
      @user = User.find(params[:id])
      flash[:notice] = "User <strong>#{@user.email}</strong> has been deleted"
      @user.destroy
      redirect_to admin_users_url
    end

    def delete_image
      @user.image.destroy
      respond_to do |format|
        format.js   { render text: "The profile picture has been deleted." }
        format.html { redirect_to(edit_admin_user_url(@user)) }
      end
    end

    protected

    def find_user
      @user = User.find(params[:id])
    end

    def user_params
      permitted_params = %i[name email image image_id]
      if policy(User).manage?
        permitted_params += [:activated,
                             { role_names: [] }]
      end
      if User.none? || (@user && policy(@user).change_password?)
        permitted_params += %i[password confirm_password]
      end
      params.require(:user).permit(permitted_params)
    end

    def user_params_with_roles
      return user_params unless policy(User).manage?

      { role_names: [] }.merge(user_params)
    end

    def require_no_users
      return unless User.any?

      flash[:error] = t("pages_core.account_holder_exists")
      redirect_to(admin_users_url)
    end
  end
end
