# encoding: utf-8

class ApplicationController < PagesCore::BaseController #:nodoc:
  helper :all
  protect_from_forgery with: :exception
end
