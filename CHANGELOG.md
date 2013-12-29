# Changelog

* #### New API for admin menu items

  Menu items are no longer defined in the controller, but rather
  in the PagesCore::Plugin subclass.

  This removes the need to override Admin::AdminController in apps with
  custom modules, and provides a clean API for admin plugins.

* #### ThinkingSphinx updated to 3.0

  See http://pat.github.io/thinking-sphinx/upgrading.html

* #### Removed `truncate` methods

  The truncate helper method and String#truncate have been removed,
  exposing Rails' own methods.

* #### CacheObserver removed

  CacheObserver has been replaced with the PagesCore::Sweepable concern.

  `:cache_observer` should be removed from the list of observers in
  config/application.rb.

* #### Strong Parameters

  Strong parameters are supported and required everywhere

* #### Updated to Rails 4.0

  Rails 3.x is no longer supported, ~> 4.0.2 is required due to security
  vulnerabilities.
