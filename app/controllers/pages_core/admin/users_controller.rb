# encoding: utf-8

class PagesCore::Admin::UsersController < Admin::AdminController

  before_filter :require_authentication, :except => [:new_password, :welcome, :create_first]
  before_filter :find_user,       :only => [:edit, :update, :show, :destroy, :delete_image, :update_openid]
  before_filter :verify_editable, :only => [:delete_image, :update, :destroy, :edit, :update_openid]

  protected

    def find_user
      @user = User.find(params[:id])
    end

    def verify_editable
      unless @user.editable_by?(@current_user)
        flash[:error] = "Only the account holder can edit this person"
        redirect_to admin_user_path(@user) and return
      end
    end

  public

    def list
      redirect_to :action => "index"
    end

    def index
      respond_to do |format|
        format.html do
          @users = User.find(:all, :order => 'realname', :conditions => {:is_activated => true}).reject{|user| user.email.match(/@manualdesign\.no/)}
        end
        format.xml do
          #@users = User.find(:all, :order => 'realname')
          render :xml => @users.to_xml
        end
      end
    end

    def deactivated
      @users = User.find_deactivated
    end

    def welcome
      unless User.count == 0
        raise "Account holder already created"
      end
      @user = User.new
    end

    def create_first
      if User.count == 0
        attributes = params[:user].merge({:is_admin => true, :is_activated => true})

        unless attributes[:openid_url].blank?
          new_openid_url = attributes[:openid_url]
          attributes.delete(:openid_url)
        end

        @user = User.create(attributes)
        if @user.valid?
          @current_user = @user
          @current_user.update_attribute(:last_login_at, Time.now)
          session[:current_user_id] = @current_user.id
          set_authentication_cookies

          if new_openid_url
            unless start_openid_session(new_openid_url,
              :success   => update_openid_admin_user_url(@user),
              :fail      => edit_admin_user_url(@user)
            )
              flash.now[:error] = "Not a valid OpenID URL"
              render :action => :edit
            end
          end
        end
      else
        raise "Account holder already created"
      end
      redirect_to admin_default_url and return
    end

    def new_password
      if params[:username]
        if user = User.find_by_username_or_email(params[:username].to_s)
          new_password = user.generate_new_password
          user.save
          AdminMailer.deliver_new_password(
            :user      => user,
            :site_name => PagesCore.config(:site_name),
            :password  => new_password,
            :login_url => admin_default_url
          )
          flash[:notice] = "A new password has been sent to your email address"
          redirect_to "/admin" and return
        end
      end
    end

    def login
      redirect_to admin_default_url
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
      @user = User.new( params[:user] )
      @user.creator  = @current_user
      if @user.save
        AdminMailer.deliver_new_user( :user => @user, :site_name => PagesCore.config( :site_name ), :login_url => admin_default_url )
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
      original_username = @user.username

      update_params = params[:user]
      unless update_params[:openid_url].blank?
        new_openid_url = update_params[:openid_url] if @user == @current_user && update_params[:openid_url] != @user.openid_url
        update_params.delete(:openid_url)
      end

      if @user.update_attributes( params[:user] )
        # Send an email notification if the username or password changes
        if ( params[:user][:username] && params[:user][:username] != original_username ) || ( params[:user][:password] && !params[:user][:password].blank? )
          AdminMailer.deliver_user_changed(
            :user       => @user,
            :site_name  => PagesCore.config( :site_name ),
            :login_url  => admin_default_url,
            :updated_by => @current_user
          )
        end
        @current_user = @user if @user == @current_user
        if new_openid_url
          unless start_openid_session(new_openid_url,
            :success   => update_openid_admin_user_url(@user),
            :fail      => edit_admin_user_url(@user)
          )
            flash.now[:error] = "Not a valid OpenID URL"
            render :action => :edit
          end
        else
          flash[:notice] = "Your changed to #{@user.realname} were saved."
          redirect_to admin_users_path
        end
      else
        flash.now[:error] = "There were problems saving your changes."
        render :action => :edit
      end
    end

    def update_openid
      if session[:authenticated_openid_url]
        @user.update_attribute(:openid_url, session[:authenticated_openid_url])
      end
      flash[:notice] = "Your changed to #{@user.realname} were saved."
      redirect_to admin_users_path
    end

    def destroy
      @user = User.find( params[:id] )
      flash[:notice] = "User <strong>#{@user.username}</strong> has been deleted"
      @user.destroy
      redirect_to :action => :list
    end

    def delete_image
      @user.image.destroy
      respond_to do |format|
        format.js   { render :text => "The profile picture has been deleted." }
        format.html { redirect_to( edit_admin_user_path( @user ) ) }
      end
    end

end
