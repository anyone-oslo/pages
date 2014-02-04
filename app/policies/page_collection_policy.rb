class PageCollectionPolicy < CollectionPolicy
  def new?
    user.has_role?(:pages)
  end

  alias_method :reorder?, :create?
  alias_method :import_xml?, :create?
end