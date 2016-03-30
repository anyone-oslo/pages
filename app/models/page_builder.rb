# encoding: utf-8

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
    def build(user, locale: nil, parent: nil, &block)
      new(user, locale: locale, parent: parent)
        .run(&block)
    end
  end

  def initialize(user, locale: nil, parent: nil)
    @user = user
    @locale = locale || I18n.default_locale
    @parent = parent
  end

  def page(name, options = {}, &block)
    page = Page.create(
      { name: name }
        .merge(default_options)
        .merge(options)
    )
    if block_given?
      self.class
          .new(user, locale: locale, parent: page)
          .run(&block)
    end
    page
  end

  def run(&block)
    instance_eval(&block)
  end

  private

  def default_options
    {
      author: user,
      parent: parent,
      status: 2,
      locale: locale
    }
  end
end
