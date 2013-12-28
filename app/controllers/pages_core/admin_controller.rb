# encoding: utf-8

# All admin controllers inherit Admin::AdminController, which provides layout, authorization
# and other common code for the Admin set of controllers.
class PagesCore::AdminController < ApplicationController
  before_action :set_i18n_locale
  before_action :require_authentication
  before_action :restore_persistent_params
  after_action  :save_persistent_params

  layout "admin"

  def redirect
    if Page.news_pages.any?
      redirect_to news_admin_pages_url(@locale)
    else
      redirect_to admin_pages_url(@locale)
    end
  end

  protected

    def set_i18n_locale
      I18n.locale = :en
    end

    # Verifies the login. Redirects to users/welcome if the users table is empty. If not, renders the login screen.
    def require_authentication
      unless @current_user && @current_user_is_admin
        if User.count < 1
          redirect_to welcome_admin_users_url and return
        else
          redirect_to login_admin_users_url and return
        end
      end
    end

    # Loads persistent params from user model and merges with session.
    def restore_persistent_params
      if @current_user and @current_user.persistent_data?
        session[:persistent_params] ||= Hash.new
        session[:persistent_params] = @current_user.persistent_data.merge( session[:persistent_params] )
      end
    end

    # Saves persistent params from session to User model if applicable.
    def save_persistent_params
      if @current_user and session[:persistent_params]
        @current_user.persistent_data = session[:persistent_params]
        @current_user.save
      end
    end


    # --- HELPERS ---

    # Get name of class with in lowercase, with underscores.
    def self.underscore
      ActiveSupport::Inflector.underscore( self.to_s ).split( /\// ).last
    end

    # Add a stylesheet
    def add_stylesheet( css_file )
      @admin_stylesheets ||= Array.new
      @admin_stylesheets << "admin/#{css_file}"
    end

    # Load subversion info
    # Get a persistent param
    def persistent_param( key, default=nil, options={} )
      namespace = options[:namespace] || self.class.to_s

      # someone set us up the hash
      session[:persistent_params]                 ||= Hash.new
      session[:persistent_params][namespace]      ||= Hash.new

      if options[:preserve_nil]
        session[:persistent_params][namespace][key] = default unless session[:persistent_params][namespace].has_key? key
      else
        session[:persistent_params][namespace][key] ||= default
      end

      # store the posted param if provided
      session[:persistent_params][namespace][key] = params[key] if params.has_key? key

      # conversions
      if session[:persistent_params][namespace][key].kind_of? String
        session[:persistent_params][namespace][key] = true  if session[:persistent_params][namespace][key] == "true"
        session[:persistent_params][namespace][key] = false if session[:persistent_params][namespace][key] == "false"
      end

      # ..and return it
      session[:persistent_params][namespace][key]
    end

end
