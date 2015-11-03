# Pages

[![Build Status](https://travis-ci.org/manualdesign/pages.svg?branch=master)](https://travis-ci.org/manualdesign/pages) [![Code Climate](https://codeclimate.com/github/manualdesign/pages/badges/gpa.svg)](https://codeclimate.com/github/manualdesign/pages) [![Test Coverage](https://codeclimate.com/github/manualdesign/pages/badges/coverage.svg)](https://codeclimate.com/github/manualdesign/pages)

## Dependencies

* Sphinx

## Getting started

Pages is a Ruby on Rails-based CMS tailored for Rails developers.

The box does not include any themes or templates. Rather, it aims to
make it as easy as possible to build your site from scratch, harnessing
all the power of Rails and it's assets pipeline.

To get started, you'll need a Rails app. A freshly generated one will
do. Add it to your Gemfile:

```ruby
gem "pages_core"
```

Next, run the installer (which will ask you a few questions), and then
the migrations.

```sh
bin/rails g pages_core:install
bin/rake db:migrate
```

You'll also need a running Sphinx process:

```sh
bin/rake ts:configure
bin/rake ts:start
```

You should now be ready to fire up the server and visit /admin to
create your first user account.

## Quick tour

Pages is all about the `Page` model - a site is a tree of Pages. Every
page has a template (which corresponds to the files in
`app/views/pages/templates`). Here's a sample template:

```html
<h1>
  <%= @page.name %>
</h1>

<% if @page.excerpt? %>
  <%= @page.excerpt.to_html %>
<% end %>

<% if @page.body? %>
  <%= @page.body.to_html %>
<% end %>

<% if @page.pages.any? %>
  <h2>
    More stuff
  </h2>
  <ul>
    <% @page.pages.each do |p| %>
      <li>
        <%= link_to p.name, page_path(locale, p) %>
      </li>
    <% end %>
  </ul>
<% end %>
```

Every template has one or more blocks of content, configured in
the `page_templates.rb` initializer. `name`, `excerpt` and `body`
in the example above are the defaults, but this is fully customizable
along with other optional features like images, file uploads, tags and more.

You'll also notice that the page links have a locale param. Pages does support
localizations:

```ruby
@page.localize(:en).name # => "Hello"
@page.localize(:fr).name # => "Bonjour"
```

All the helpers and controllers will automatically set the locale for
you and it propagates across relations, so you'll rarely end up
interacting with it directly in this fashion.

## License

Pages is licensed under the
[MIT License](http://www.opensource.org/licenses/MIT).
