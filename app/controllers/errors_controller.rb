# frozen_string_literal: true

class ErrorsController < ApplicationController
  include PagesCore::DocumentTitleController

  layout "errors"

  def show
    render_error params[:id].to_i
  end

  def forbidden
    render_error 403
  end

  def not_found
    render_error 404
  end

  def unacceptable
    render_error 422
  end

  def unauthorized
    render_error 401
  end

  def internal_error
    exception = request.env["action_dispatch.exception"]
    if exception
      wrapper = ActionDispatch::ExceptionWrapper.new(nil, exception)
      render_error wrapper.status_code
    else
      render_error 500
    end
  end
end
