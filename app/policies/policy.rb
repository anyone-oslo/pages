class Policy
  attr_reader :user, :record

  def initialize(user, record=nil)
    @user = user
    @record = record
  end
end