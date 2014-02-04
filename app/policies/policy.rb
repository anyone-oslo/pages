class Policy
  attr_reader :user, :record

  def initialize(user, record=nil)
    @user = user
    @record = record
  end

  def show
    false
  end

  def edit?
    false
  end

  alias_method :update?, :edit?
  alias_method :destroy?, :edit?
end