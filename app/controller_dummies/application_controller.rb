# frozen_string_literal: true

class ApplicationController < PagesCore::BaseController # :nodoc:
  helper :all
  protect_from_forgery with: :exception
end
