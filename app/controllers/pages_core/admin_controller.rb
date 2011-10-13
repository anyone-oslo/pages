# All admin controllers inherit Admin::AdminController, which provides layout, authorization
# and other common code for the Admin set of controllers.
class PagesCore::AdminController < ApplicationController

	layout "admin"

	def redirect
		redirect_to (Page.news_pages?) ? news_admin_pages_url(:language => @language) : admin_pages_url(:language => @language)
	end

	protected

	# --- FILTERS ---

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
	before_filter :require_authentication, :except => [:new_password, :welcome]

	# Builds the admin menu tabs.
	def build_admin_tabs
		if Page.news_pages?
			register_menu_item "News", hash_for_news_admin_pages_path({:language => @language}), :pages, { :only_actions => ['news', 'new_news'] }
		end
		register_menu_item "Pages", hash_for_admin_pages_path({:language => @language}), :pages, { :skip_actions => ['news', 'new_news'] }

		#register_menu_item "Partials", hash_for_admin_partials_path( { :language => @language } ), :pages
		#register_menu_item( "Account", hash_for_admin_accounts_path, :account ) if @current_user && ( @current_user.account_holder? || @current_user.is_special? )
		register_menu_item "Users",  hash_for_admin_users_path, :account
	end
	before_filter :build_admin_tabs

	# Loads persistent params from user model and merges with session.
	def restore_persistent_params
		if @current_user and @current_user.persistent_data?
			session[:persistent_params] ||= Hash.new
			session[:persistent_params] = @current_user.persistent_data.merge( session[:persistent_params] )
		end
	end
	before_filter :restore_persistent_params

	# Saves persistent params from session to User model if applicable.
	def save_persistent_params
		if @current_user and session[:persistent_params]
			@current_user.persistent_data = session[:persistent_params]
			@current_user.save
		end
	end
	after_filter :save_persistent_params


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
		options[:skip_actions] ||= []
		@admin_menu << { :name => name, :url => url, :class => class_name, :options => options }
	end

	# Add a stylesheet
	def add_stylesheet( css_file )
		@admin_stylesheets ||= Array.new
		@admin_stylesheets << "admin/#{css_file}"
	end

	# Load subversion info
	def svn_info
		@subversion_info = HashWithIndifferentAccess.new
		`svn info`.split(/\n/).each do |line|
			line = line.split(/:[\s]*/, 2)
			@subversion_info[line[0].downcase.gsub(/[\s]+/, '_')] = line[1]
		end
	end

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
