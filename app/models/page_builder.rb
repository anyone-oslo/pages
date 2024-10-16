# frozen_string_literal: true

# # PageBuilder
#
# PageBuilder is a simple DSL for building pages, for use in ie. seeds.rb
#
# Example:
#
#   PageBuilder.build(User.first) do
#     page "Home", template: "home"
#     page "Products" do
#       page "Product 1"
#       page "Product 2"
#     end
#     page "Contact", unique_name: "contact"
#   end
class PageBuilder
  attr_reader :user, :locale, :parent

  class << self
    def build(user, locale: nil, parent: nil, &)
      new(user, locale:, parent:)
        .run(&)
    end
  end

  def initialize(user, locale: nil, parent: nil)
    @user = user
    @locale = locale || I18n.default_locale
    @parent = parent
  end

  def page(name, options = {}, &)
    page = Page.create(
      { name: }.merge(default_options).merge(options)
    )
    if block_given?
      self.class
          .new(user, locale:, parent: page)
          .run(&)
    end
    page
  end

  def run(&)
    instance_eval(&)
  end

  private

  def default_options
    { author: user,
      parent:,
      status: 2,
      locale: }
  end
end
