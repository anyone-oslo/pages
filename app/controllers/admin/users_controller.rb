# encoding: utf-8

class Admin::UsersController < Admin::AdminController
  before_action :require_authentication, except: [:new_password, :welcome, :create_first, :login, :reset_password]
  before_action :require_no_users,       only: [:welcome, :create_first]
  before_action :find_user,              only: [:edit, :update, :show, :destroy, :delete_image, :update_openid]
  before_action :verify_editable,        only: [:delete_image, :update, :destroy, :edit, :update_openid]

  def index
    @users = User.activated.reject{|user| user.email.match(/@manualdesign\.no/)}
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
      @current_user = @user
      current_user.update(last_login_at: Time.now)
      session[:current_user_id] = current_user.id
      set_authentication_cookies

      # Start OpenID session
      if params[:user][:openid_url]
        unless start_openid_session(params[:user][:openid_url],
          success: update_openid_admin_user_url(@user),
          fail:    edit_admin_user_url(@user)
        )
          flash.now[:error] = "Not a valid OpenID URL"
          render :action => :edit
        end
      else
        redirect_to admin_default_url
      end
    else
      redirect_to admin_default_url
    end
  end

  def new_password
  end

  def reset_password
    if params[:username]
      if user = User.find_by_username_or_email(params[:username].to_s)
        new_password = user.generate_new_password
        user.save

        AdminMailer.new_password(user, new_password, admin_default_url).deliver
        flash[:notice] = "A new password has been sent to your email address"
        redirect_to login_admin_users_path and return
      end
    end
  end

  def login
    if logged_in?
      redirect_to admin_default_url
    end
  end

  def logout
    flash[:notice] = "You have been logged out."
    deauthenticate!( :forcefully => true )
    redirect_to( "/admin" ) and return
  end

  def new
    @user = User.new
    @user.is_admin     = true
    @user.is_activated = true
  end

  def create
    @user = User.new(user_params)
    @user.creator = current_user
    if @user.save
      AdminMailer.new_user(@user, admin_default_url).deliver
      flash[:notice] = "#{@user.realname} has been invited."
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
      # Send an email notification if the username or password changes
      if params[:user][:password] || @user.previous_changes[:name]
        AdminMailer.user_changed(@user, admin_default_url, current_user).deliver
      end

      # OpenID URL changed?
      if @user == current_user && params[:user][:openid_url] != @user.openid_url
        unless start_openid_session(params[:user][:openid_url],
          success: update_openid_admin_user_url(@user),
          fail:    edit_admin_user_url(@user)
        )
          flash.now[:error] = "Not a valid OpenID URL"
          render :action => :edit
        end
      else
        flash[:notice] = "Your changed to #{@user.realname} were saved."
        redirect_to admin_users_url
      end
    else
      flash.now[:error] = "There were problems saving your changes."
      render :action => :edit
    end
  end

  def update_openid
    if session[:authenticated_openid_url]
      @user.update(openid_url: session[:authenticated_openid_url])
    end
    flash[:notice] = "Your changed to #{@user.realname} were saved."
    redirect_to admin_users_url
  end

  def destroy
    @user = User.find( params[:id] )
    flash[:notice] = "User <strong>#{@user.username}</strong> has been deleted"
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
    params.require(:user).permit(
      :realname, :email, :mobile, :web_link,
      :image, :username, :password, :is_activated, :is_admin
    )
  end

  def require_no_users
    if User.any?
      flash[:error] = "Account holder already exists"
      redirect_to admin_users_url and return
    end
  end

  def verify_editable
    unless @user.editable_by?(current_user)
      flash[:error] = "Only the account holder can edit this person"
      redirect_to admin_user_url(@user) and return
    end
  end

end
