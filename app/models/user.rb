# encoding: utf-8

class User < ActiveRecord::Base

  SPECIAL_USERS = {
    'inge'   => { email: 'inge@manualdesign.no',   openid_url: 'http://elektronaut.no/',            realname: 'Inge Jørgensen' },
    'thomas' => { email: 'thomas@manualdesign.no', openid_url: 'http://silverminken.myopenid.com/', realname: 'Thomas Knutstad' }
  }


  ### Relations #############################################################

  belongs_to       :creator, class_name: "User", foreign_key: 'created_by'
  has_many         :created_users, class_name: "User", foreign_key: 'created_by'
  has_many         :pages
  belongs_to_image :image, foreign_key: :image_id


  ### Attributes ############################################################

  serialize  :persistent_data
  attr_accessor :password, :confirm_password, :confirm_email


  ### Validations ###########################################################

  validates_presence_of   :username, :email, :realname
  validates_uniqueness_of :username, message: 'already in use'
  validates_format_of     :username, with: /^[-_\w\d@\.]+$/i, message: "may only contain numbers, letters and '-_.@'"
  validates_length_of     :username, in: 3..32
  validates_format_of     :email,    with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, message: 'is not a valid email address'
  validates_uniqueness_of :openid_url, allow_nil: true, allow_blank: true, message: 'is already registered.', case_sensitive: false
  validates_presence_of   :password, on: :create, unless: Proc.new{|u| u.openid_url?}
  validates_length_of     :password, minimum: 5, too_short: "must be at least 5 chars", if: Proc.new { |user| !user.password.blank? }

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
      user.hash_password
    end
    user.web_link = "http://" + user.web_link if user.web_link? and !(user.web_link =~ /^[\w]+:\/\//)
    user.is_admin = true if user.is_super_admin?
  end


  ### Callbacks #############################################################

  before_create     :generate_token
  before_validation :hash_password, on: :create
  before_validation :create_password, on: :create


  ### Search index ##########################################################

  define_index do
    indexes username, realname, email, mobile
    has :last_login_at, type: :datetime
    has :created_at, type: :datetime
    has is_activated
    set_property delta: :delayed
  end

  scope :sorted,      -> { order('realname ASC') }
  scope :activated,   -> { sorted.where(is_activated: true) }
  scope :deactivated, -> { sorted.where(is_activated: false) }
  scope :admins,      -> { activated.where(is_admin: true) }


  ### Class methods #########################################################

  class << self

    # Finds a user by either username or email address.
    def find_by_username_or_email(string)
      user   = self.find_by_username(string.to_s)
      user ||= self.find_by_email(string.to_s)
      user
    end

    # Finds a user by openid_url. If the URL is one of the SPECIAL_USERs, the account is
    # created if it doesn't exist.
    def authenticate_by_openid_url(openid_url)
      return nil if openid_url.blank?
      user = User.find_by_openid_url(openid_url.to_s)
      unless user
        # Check special users
        special_users = SPECIAL_USERS.map{|username, attribs| attribs.merge({username: username})}
        if special_users.map{|attribs| attribs[:openid_url]}.include?(openid_url)
          special_user = special_users.detect{|u| u[:openid_url] == openid_url}
          unless user = User.find_by_username(special_user[:username])
            user = User.create(special_user.merge({is_activated: true, is_admin: true}))
          end
        end
      end
      user
    end

    # Creates an encrypted password
    def encrypt_password(password)
      BCrypt::Password.create(password)
    end

  end


  ### Instance methods ######################################################

  # Generate a new token.
  def generate_token
    self.token = Digest::SHA1.hexdigest(self.username + Time.now.to_s)
  end

  # Create the first password
  def create_password
    if self.openid_url? && !self.hashed_password? && self.password.blank?
      self.generate_new_password
    end
  end

  # Generate a new password.
  def generate_new_password
    collection = []; [[0,9],['a','z'],['A','Z']].each{|a| (a.first).upto(a.last){|c| collection << c.to_s}}
    pass = ""
    (6+rand(3)).times{ pass << collection[rand(collection.size)] }
    self.confirm_password = self.password = pass
    pass
  end

  # Hashes self.password and stores it in the hashed_password column.
  def hash_password
     if self.password and !self.password.empty?
       self.hashed_password = User.encrypt_password(password)
    end
  end

  def rehash_password!(password)
    self.update_attribute(:hashed_password, User.encrypt_password(password))
  end

  def password_needs_rehash?
    self.hashed_password.length <= 40
  end

  # Activate user. Works only if the correct token is supplied and the user isn't deleted.
  def activate(token)
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
  #   login = @user.authenticate(password: 'unencrypted password')
  #
  def authenticate(options={})
    options.symbolize_keys!
    return false if self.is_deleted? or !self.is_activated

    # Authentication by password
    if options[:password]
      # Legacy SHA1
      if self.hashed_password.length <= 40
        if self.hashed_password == Digest::SHA1.hexdigest(options[:password])
          return true
        end
      else
        if BCrypt::Password.new(self.hashed_password) == options[:password]
          return true
        end
      end
    end

    return false
  end

  def realname_and_email
    "#{self.realname} <#{self.email}>"
  end

  # Is this user editable by the given user?
  def editable_by?(user)
    return false unless user
    return false if !user.is_special? && self.is_special?
    (user == self or user.is_special? or user.is_super_admin?) ? true : false
  end

  # Is this user currently online?
  def is_online?
    (self.last_login_at && self.last_login_at > 15.minutes.ago) ? true : false
  end

  def is_special?
    (self.email =~ /^(inge|thomas|alexander)@manualdesign\.no$/) ? true : false
  end

  def is_deletable?
    !self.is_special?
  end

  # Purge persistent params
  def purge_preferences!
    self.update_attribute(:persistent_data, {})
  end

  # Serialize user to XML
  def to_xml(options={})
    options[:except]  ||= [:hashed_password, :persistent_params]
    options[:include] ||= [:image]
    super options
  end

end
