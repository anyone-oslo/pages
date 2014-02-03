class UserPolicy
  attr_reader :user, :record

  def initialize(user, record=nil)
    @user = user
    @record = record
  end

  def create?
    user.has_role?(:users)
  end

  alias_method :destroy?, :create?

  def edit?
    user == record || user.has_role?(:users)
  end

  alias_method :delete_image?, :edit?
  alias_method :update?, :edit?
  alias_method :edit?, :edit?
  alias_method :update_openid?, :edit?
end