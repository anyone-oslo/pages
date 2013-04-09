# encoding: utf-8

# All admin controllers inherit Admin::AdminController, which provides layout, authorization
# and other common code for the Admin set of controllers.
class PagesCore::AdminController < ApplicationController

  before_filter :set_i18n_locale
  before_filter :require_authentication, :except => [:new_password, :welcome]
  before_filter :build_admin_tabs
  before_filter :restore_persistent_params
  after_filter  :save_persistent_params

  layout "admin"

  def redirect
    if Page.news_pages?
      redirect_to news_admin_pages_url(:language => @language)
    else
      redirect_to admin_pages_url(:language => @language)
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
          redirect_to :controller => :users, :action => :welcome and return false
        else
          render :template => 'admin/users/login' and return false
        end
      end
    end

    # Builds the admin menu tabs.
    def build_admin_tabs
      if Page.news_pages?
        register_menu_item(
          "News", hash_for_news_admin_pages_path({:language => @language}), :pages,
          :current => Proc.new {
            params[:controller] == 'admin/pages' &&
            (params[:action] == 'news' || (@page && @page.parent_page && @page.parent_page.news_page?))
          }
        )
      end
      register_menu_item "Pages", hash_for_admin_pages_path({:language => @language}), :pages
      register_menu_item "Users", hash_for_admin_users_path, :account

      # Register menu items from plugins
      PagesCore::Plugin.plugins.each do |plugin_class|
        plugin = plugin_class.new
        if plugin.respond_to?(:admin_menu_tabs)
          plugin.admin_menu_tabs.each do |menu_item|
            register_menu_item menu_item[:label], menu_item[:url], (menu_item[:group] || :pages_plugins)
          end
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

    # Register a menu item (for extending with custom controllers
    def register_menu_item( name, url={}, class_name=:custom, options={} )
      @admin_menu      ||= []
      url[:controller] ||= "admin/#{name.underscore}"
      url[:action]     ||= 'index'
      @admin_menu << { :name => name, :url => url, :class => class_name, :options => options }
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
