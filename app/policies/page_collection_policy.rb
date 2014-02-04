class PageCollectionPolicy < CollectionPolicy
  def create?
    user.has_role?(:pages)
  end

  alias_method :new?, :create?
  alias_method :reorder?, :create?
  alias_method :import_xml?, :create?
end