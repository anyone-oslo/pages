class PagePolicy
  attr_reader :user, :record

  def initialize(user, record=nil)
    @user = user
    @record = record
  end

  def create?
    user.has_role?(:pages)
  end

  alias_method :new?, :create?
  alias_method :reorder?, :create?
  alias_method :import_xml?, :create?

  def edit?
    user == record.author || user.has_role?(:pages)
  end

  alias_method :update?, :edit?
  alias_method :destroy?, :edit?
end