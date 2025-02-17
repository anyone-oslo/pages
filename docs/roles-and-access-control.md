# Roles and access control

Roles are defined in `config/roles.yml`:

```yaml
widgets:
  description: "Can manage widgets"
  default: false
```

or with `Role.define`:

```ruby
Role.define :widgets, "Can manage widgets"
```

You can now assign your role to users:

```ruby
user.has_role?(:widgets) # => false
user.roles.create(name: :widgets)
user.has_role?(:widgets) # => true
```

and create a policy for your widgets:

```ruby
class WidgetPolicy < Policy
  def edit?
    user == record.owner or user.has_role?(:widgets)
  end
end
```

Note: You don't have to use the roles system here. Any code that verifies the relationship between `user` and `record` will do.

To check a policy:

```ruby
Policy.for(user, widget).edit? # => true
```

..or rather, use the built-in helper for the logged in user in your controllers and views:

```ruby
policy(widget).edit? # => true
```

Here's a full implementation of a REST style policy for widgets:

```ruby
class WidgetPolicy < Policy
  def index?
    true
  end

  def new?
    user.has_role?(:widgets)
  end

  # create? is aliased to new? by default, but can be overriden.
  # def create?
  #   new?
  # end

  def show?
    true
  end
  
  def edit?
    user == record.owner or user.has_role?(:widgets)
  end

  # update? and destroy? is aliased to edit? by default, but can be overriden.
  # def update?
  #   edit?
  # end

  # def destroy?
  #   edit?
  # end
end
```

To verify your policies in a controller, you can use the `require_authorization` helper. Here's a sample implementation:

```ruby
class WidgetController < ApplicationController
  before_action :find_widget, only: %i[show edit update destroy]
  require_authorization

  ...

  protected

  def find_widget
    @widget = Widget.find(params[:id)
  end
end
```

The class and instance variable are inferred from the name of the controller class, but can be specified manually:

```ruby
require_authorization(object: Widget, 
                      instance: proc { @widget })
```

Any unauthorised requests will now trigger a `PagesCore::NotAuthorized` error, which in production will be rendered as a 403 response with a nice "You can't do that" page.
