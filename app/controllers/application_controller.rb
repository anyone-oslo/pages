class ApplicationController < PagesCore::ApplicationController
  helper :all
  protect_from_forgery
end
