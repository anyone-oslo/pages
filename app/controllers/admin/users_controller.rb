# encoding: utf-8

class Admin::UsersController < Admin::AdminController
  before_action :require_authentication, except: [:new, :create, :login]
  before_action :require_no_users,       only: [:new, :create]
  before_action :find_user,              only: [:edit, :update, :show, :destroy, :delete_image]

  require_authorization User, proc { @user },
                        member:     [:delete_image, :update, :destroy, :edit],
                        collection: [:index, :deactivated, :new, :create]

  def index
    @users = User.activated
    @invites = Invite.all.order('created_at DESC')
    respond_to do |format|
      format.html do
      end
      format.xml do
        render xml: @users.to_xml
      end
    end
  end

  def deactivated
    @users = User.deactivated
  end

  def login
    if logged_in?
      redirect_to admin_default_url
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.create(user_params)
    if @user.valid?
      authenticate!(@user)
      redirect_to admin_default_url
    else
      render action: :new
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml { render xml: @user.to_xml }
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:notice] = "Your changed to #{@user.name} were saved."
      redirect_to admin_users_url
    else
      flash.now[:error] = "There were problems saving your changes."
      render action: :edit
    end
  end

  def destroy
    @user = User.find( params[:id] )
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
    permitted_params = [
      :name, :email, :image
    ]
    if policy(User).manage?
      permitted_params += [:activated, role_names: []]
    end
    if @user && policy(@user).change_password?
      permitted_params += [:password, :confirm_password]
    end
    params.require(:user).permit(permitted_params)
  end

  def require_no_users
    if User.any?
      flash[:error] = "Account holder already exists"
      redirect_to admin_users_url and return
    end
  end
end
