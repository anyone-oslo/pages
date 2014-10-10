# encoding: utf-8

class Admin::UsersController < Admin::AdminController
  before_action :require_authentication, except: [:welcome, :create_first, :login]
  before_action :require_no_users,       only: [:welcome, :create_first]
  before_action :find_user,              only: [:edit, :update, :show, :destroy, :delete_image]

  require_authorization User, proc { @user },
                        member:     [:delete_image, :update, :destroy, :edit],
                        collection: [:index, :deactivated, :new, :create, :create_first]

  def index
    @users = User.activated
    @invites = Invite.all.order('created_at DESC')
    respond_to do |format|
      format.html do
      end
      format.xml do
        render :xml => @users.to_xml
      end
    end
  end

  def deactivated
    @users = User.deactivated
  end

  def welcome
    @user = User.new
  end

  def create_first
    @user = User.create(user_params)
    if @user.valid?
      authenticate!(@user)
    end
    redirect_to admin_default_url
  end

  def login
    if logged_in?
      redirect_to admin_default_url
    end
  end

  def new
    @user = User.new(activated: true)
    Role.roles.each do |role|
      @user.roles.new(name: role.name) if role.default
    end
  end

  def create
    @user = User.new(user_params)
    @user.creator = current_user
    @user.generate_new_password
    if @user.save
      AdminMailer.new_user(@user, admin_default_url).deliver
      flash[:notice] = "#{@user.name} has been invited."
      redirect_to :action => :index
    else
      flash.now[:error] = "There were problems inviting this person."
      render :action => :new
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml { render :xml => @user.to_xml }
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
      render :action => :edit
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
      format.js   { render :text => "The profile picture has been deleted." }
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
