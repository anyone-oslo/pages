class User < ActiveRecord::Base
	
	belongs_to :creator,
			   :class_name     => "User",
			   :foreign_key    => 'created_by'
			   
	has_many   :created_users,
	           :class_name     => "User",
			   :foreign_key    => 'created_by'
			   
	serialize  :persistent_data
	

	# Relations
	has_many :permissions,     :as => :owner
	has_many :pages
	
	belongs_to :group
	belongs_to_image :image, :foreign_key => :image_id
	
	# Validations
	validates_presence_of   :username, :email, :realname
	validates_uniqueness_of :username, :message => 'already in use'
	validates_format_of     :username, :with => /^[-_\w\d@\.]+$/i, :message => "may only contain numbers, letters and '-_.@'"
	validates_length_of     :username, :in => 3..32
	validates_format_of     :email,    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => 'is not a valid email address'
	validates_uniqueness_of :openid_url, :allow_nil => true, :allow_blank => true, :message => 'is already registered.', :case_sensitive => false

	validates_presence_of   :password, :on => :create, :unless => Proc.new{|u| u.openid_url?}
	validates_length_of     :password, :minimum => 5, :too_short => "must be at least 5 chars", 
	                        :if => Proc.new { |user| !user.password.blank? }

	attr_accessor :password, :confirm_password, :confirm_email, :password_changed
	
	SPECIAL_USERS = {
		'inge'      => {:email => 'inge@manualdesign.no',      :openid_url => 'http://elektronaut.no/',            :realname => 'Inge Jørgensen'},
		'alexander' => {:email => 'alexander@manualdesign.no', :openid_url => 'http://binaerpilot.no/',            :realname => 'Alexander Støver'},
		'thomas'    => {:email => 'thomas@manualdesign.no',    :openid_url => 'http://silverminken.myopenid.com/', :realname => 'Thomas Knutstad'}
	}

	before_validation_on_create do |user|
		if user.openid_url? && !user.hashed_password? && user.password.blank?
			user.generate_new_password
		end
	end

	before_create               :generate_token
	before_validation_on_create :hash_password

	validate do |user|
		# Normalize OpenID URL
		unless user.openid_url.blank?
			user.openid_url = "http://"+user.openid_url unless user.openid_url =~ /^https?:\/\//
			user.openid_url = OpenID.normalize_url(user.openid_url)
		end

		# Handle special users
		if special_user = SPECIAL_USERS[user.username]
			user.openid_url ||= special_user[:openid_url]
			user.errors.add(:username, 'is reserved') unless user.email == special_user[:email]
		end

		# Check password
		if user.password and !user.password.empty?
			#if user.password == user.confirm_password
				user.hash_password
			#else
			#	user.errors.add( :confirm_password, 'must be confirmed' ) 
			#end
		end
		user.web_link = "http://"+user.web_link if user.web_link? and !( user.web_link =~ /^[\w]+:\/\// )
		user.is_admin = true if user.is_super_admin?
	end
	
	define_index do
		# fields
		indexes username, realname, email, mobile

		# attributes
		has :last_login_at, :type => :datetime
		has :created_at, :type => :datetime
		has is_activated

		set_property :delta => :delayed
	end

	class << self # -- Class methods ------------------------------------------
	
		def authenticate_by_openid_url(openid_url)
			return nil if openid_url.blank?
			user = User.find_by_openid_url(openid_url)
			unless user
				# Check special users
				special_users = SPECIAL_USERS.map{|username, attribs| attribs.merge({:username => username})}
				if special_users.map{|attribs| attribs[:openid_url]}.include?(openid_url)
					special_user = special_users.detect{|u| u[:openid_url] == openid_url}
					unless user = User.find_by_username(special_user[:username])
						user = User.create(special_user.merge({:is_activated => true, :is_admin => true}))
					end
				end
			end
			user
		end
	
		# Find users by the first letter(s) of the username.
		def find_by_first_letter( letters )
			letters = "[#{letters}]"
			User.find( :all, :order => 'username', :conditions => [ 'is_deleted = 0 AND is_activated = 1 AND username REGEXP ?', "^"+letters ] )
		end

		# Find a user by either id or username.
		def find_by_id_or_username( id )
			( id =~ /^[\d]+$/ ) ? self.find( id ) : self.find( :first, :conditions => [ 'username = ?', id ] )
		end
		
		# Find a user by either username or email address
		def find_by_username_or_email( string )
			user   = self.find_by_username( string )
			user ||= self.find_by_email( string )
			user
		end
	
		# Find newest users.
		def latest( limit=5 )
			self.find( :all, :limit => limit, :conditions => [ "is_deleted = 0 AND is_activated = 1" ], :order => 'created_at DESC' )
		end
	
		# Find logged in users, which is any user who has been active within the last 15 minutes.
		def logged_in
			self.find( :all, :order => 'last_login_at DESC', :conditions => [ 'last_login_at > ?', 15.minutes.ago ] )
		end

		# Creates a digest hash from the given string.
		def hash_string( string )
			Digest::SHA1.hexdigest( string )
		end
		
		def admin_users
			self.find( :all, :conditions => 'is_activated = 1 AND is_admin = 1', :order => 'realname ASC' )
		end
		
		def find_deactivated
			self.find(:all, :conditions => {:is_activated => false}, :order => 'realname ASC')
		end
		
		def deactivated_count
			self.count(:all, :conditions => {:is_activated => false})
		end
	
	end # class << self -------------------------------------------------------
	
	
	# Report admin status for search
	def admin_status_for_search
		( self.is_admin? ) ? 'admin' : nil
	end


	# Generate a new token.
	def generate_token
		self.token = Digest::SHA1.hexdigest( self.username + Time.now.to_s )
	end
	
	# Generate a new password.
	def generate_new_password
		collection = []; [[0,9],['a','z'],['A','Z']].each{ |a| (a.first).upto(a.last){ |c| collection << c.to_s } }
		pass = ""
		(6+rand(3)).times{ pass << collection[rand(collection.size)] }
		self.confirm_password = self.password = pass
		pass
	end
	

	# Hashes self.password and stores it in the hashed_password column.
	def hash_password
 		if self.password and !self.password.empty?
			old_hash = self.hashed_password
			self.hashed_password = User.hash_string( self.password )
			self.password_changed = true if old_hash != self.hashed_password
		end
	end

	# Activate user. Works only if the correct token is supplied and the user isn't deleted.
	def activate( token )
		return false if self.is_deleted?
		if self.token? and token == self.token
			self.is_activated = true
			return true
		else
			return false
		end
	end
	
	# Authenticate user, returns a true if successful. Only works if the user is activated and not deleted.
	# Returns false if authentication fails.
	# 
	# Example:
	#
	#   login = @user.authenticate(:password => 'unencrypted password')
	#
	def authenticate( options={} )
		options.symbolize_keys!
		return false if self.is_deleted? or !self.is_activated

		# Authentication by password
		if options[:password] && self.class.hash_string(options[:password]) == self.hashed_password
			return true
		end

		return false
	end
	
	def realname_and_email
		"#{self.realname} <#{self.email}>"
	end
	
	# Is this user editable by the given user?
	def editable_by?( user )
		return false unless user
		return false if !user.is_special? && self.is_special?
		( user == self or user.is_special? or user.account_holder? or user.is_super_admin?) ? true : false
	end
	
	# Is this user currently online?
	def is_online?
		( self.last_login_at && self.last_login_at > 15.minutes.ago ) ? true : false
	end
	
	def is_special?
		( self.email =~ /^(inge|thomas|alexander)@manualdesign\.no$/ ) ? true : false
	end
	
	def account_holder?
		account = Account.find_or_create
		( account && account.account_holder == self ) ? true : false
	end
	
	def is_deletable?
		( !self.is_special? && !self.account_holder? ) ? true : false
	end
	
	# Purge persistent params
	def purge_preferences!
		self.update_attribute( :persistent_data, {} )
	end
	
	# Serialize user to XML
	def to_xml( options={} )
		options[:except] ||= [:hashed_password, :persistent_params]
		options[:include] ||= [:image]
		super options
	end
	
end
