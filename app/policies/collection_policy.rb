class CollectionPolicy
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def new?
    false
  end

  alias_method :index?, :new?
  alias_method :create?, :new?
end