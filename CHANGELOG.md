* #### DynamicImage 2.0

  The image backend has been replaced with DynamicImage 2.0.

  To upgrade existing applications:

  * Remove config/initializers/dynamic_image.rb
  * Add config/initializers/active_job.rb
  * Add config/initializers/dis.rb (can be generated with the manual_server gem)
  * Run migrations

* #### User accounts

  Logging in with username is now deprecated. The username is hidden everywhere, and will default to the email address.

  The password minimum length has been increased to 8 characters.

  Removed unused attributes: `token`, `is_deleted`, `born_on`, `mobile`, `web_link`.

  `User#realname` is now `User#name`

* #### Password resets

  Password resets are now handled with password reset tokens.

* #### RSpec 3.0

  RSpec has been upgraded to 3.0.