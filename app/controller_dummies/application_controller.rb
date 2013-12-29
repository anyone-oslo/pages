# encoding: utf-8

class ApplicationController < PagesCore::ApplicationController #:nodoc:
  helper :all
  protect_from_forgery
end
