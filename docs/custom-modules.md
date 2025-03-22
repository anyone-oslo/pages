# Custom modules

## Access control

See [Roles and access control](roles-and-access-control.md) for info on how to authorize users.

## Adding menu items

You can add menu items like this (by convention in `config/initializers/admin.rb`):

``` ruby
PagesCore::AdminMenuItem.register(
  "Activities",
  proc { admin_activities_path(I18n.default_locale) }
)
```

Conditional expressions are supported:

``` ruby
PagesCore::AdminMenuItem.register(
  "Schedule",
  proc { admin_schedule_events_path },
  if: proc { current_user.role?(:schedule) }
)
```

## Subscribing to events

You can use `PagesCore::PubSub` to hook into the life cycle of objects. Currently only the `create_user` and `destroy_invite` actions are available.

``` ruby
PagesCore::PubSub.subscribe(:create_user) do |payload|
  payload[:user] # => User
  payload[:invite] # => Invite or null
end

PagesCore::PubSub.subscribe(:destroy_invite) do |payload|
  payload[:invite] # => Invite
end
```

