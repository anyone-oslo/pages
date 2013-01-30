# encoding: utf-8

class ApplicationController < PagesCore::ApplicationController

  helper :all # include all helpers, all the time
  #protect_from_forgery :secret => '<%= @forgery_secret %>', :except => :report

  # Put frontend specific code in frontend_controller.rb

end
