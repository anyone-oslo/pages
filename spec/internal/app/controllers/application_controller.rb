# encoding: utf-8

class ApplicationController < PagesCore::BaseController
  # Put frontend specific code in frontend_controller.rb

  helper :all # include all helpers, all the time

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
