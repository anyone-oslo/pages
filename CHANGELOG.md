* #### Rails generator template

  A template for generating new apps has been provided. To use it, run:

  ```sh
  rails new [app name] -T -d mysql -m /path/to/pages_core/template.rb
  ```

* #### OpenID removed

  OpenID seems to be dead. All support has been removed.

* #### Unique email addresses

  Email addresses are now unique per user account

* #### Realtime indexes

  Pages now uses the realtime indexes feature of Sphinx, rather than
  relying on DelayedJob. This requires that a Sphinx process is always running.

* #### Updated to Rails 4.1

  Now runs on Rails 4.1.

* #### Language module removed

  The Language module has been removed, use I18n.default_locale
  instead of Language.default to specify the default locale.

  3 letter language codes have been deprecated in favor of
  ISO639-1.

* #### JSON rendering for pages

  Pages can now be accessed via JSON.
