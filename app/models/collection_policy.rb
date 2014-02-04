class CollectionPolicy
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def index?
    false
  end

  def new?
    false
  end

  def create?
    new?
  end
end