Rails.application.routes.draw do
  get "errors/exception" => "error_handler_tests#exception"
  get "errors/not_authorized" => "error_handler_tests#not_authorized"
  get "errors/not_found" => "error_handler_tests#not_found"
end
