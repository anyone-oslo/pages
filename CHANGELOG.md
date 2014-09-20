* #### Rails generator template

  A template for generating new apps has been provided. To use it, run:

  ```sh
  rails new [app name] -T -d mysql -m /path/to/pages_core/template.rb
  ```

* #### Page images

  Page images can now be embedded wherever `.to_html` is called.

  Examples:

  ```
  [image:19]
  [image:19 class="foo" size="100x"]
  ```

* #### OpenID removed

  OpenID seems to be dead. All support has been removed.

* #### Unique email addresses

  Email addresses are now unique per user account

* #### Username validation

  Validation of usernames is now case insensitive

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

* #### Open Graph properties

  Open Graph properties can be overriden through the `open_graph_properties`
  helper.

* #### Removed deprecated helpers

  - `head_tag` no longer accepts options.
  - `publish_time` has been removed.
  - `formatted_date` has been removed.
  - `formatted_time` has been removed.
  - `nav_link` has been removed.
  - `nav_list_items` has been removed.
  - `hash_for_translated_route` has been removed.
  - `indent` has been removed.
  - `labelled_field` has been removed.
  - `smart_time` has been removed.
  - `video_embed` and related helpers have been removed.