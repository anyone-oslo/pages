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

  def update?
    edit?
  end

  def destroy?
    edit?
  end
end