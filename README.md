# PagesCore

Pages is a CMS for Rails apps.

## Installation

### Using the template

    rails new [app name] -T -d mysql -m ~/Dev/gems/pages/template.rb

### Using the generators

Add pages_core to your Gemfile:

    gem 'pages_core', git: 'git@github.com:manualdesign/pages.git', branch: 'master'

Run Bundler:

    bundle install

And generate the config files:

    rails g pages_core:install

Now visit /admin and create your user account.

## Upgrading

Review the [changelog](CHANGELOG.md) for breaking changes.

## License

Pages is licensed under the
[MIT License](http://www.opensource.org/licenses/MIT).
