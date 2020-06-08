# frozen_string_literal: true

class ErrorHandlerTestsController < ApplicationController
  def exception
    raise StandardError, "An error occurred"
  end

  def not_authorized
    raise PagesCore::NotAuthorized
  end

  def not_found
    raise ActiveRecord::RecordNotFound
  end
end
