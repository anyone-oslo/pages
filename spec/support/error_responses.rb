# frozen_string_literal: true

module ErrorResponses
  # See: https://github.com/rails/rails/pull/11289#issuecomment-118612393
  def respond_without_detailed_exceptions
    env_config = Rails.application.env_config
    original_show_exceptions = env_config["action_dispatch.show_exceptions"]
    original_show_detailed_exceptions =
      env_config["action_dispatch.show_detailed_exceptions"]
    env_config["action_dispatch.show_exceptions"] = true
    env_config["action_dispatch.show_detailed_exceptions"] = false
    yield
  ensure
    env_config["action_dispatch.show_exceptions"] = original_show_exceptions
    env_config["action_dispatch.show_detailed_exceptions"] =
      original_show_detailed_exceptions
  end
end

RSpec.configure do |config|
  config.include ErrorResponses

  config.around(realistic_error_responses: true) do |example|
    respond_without_detailed_exceptions(&example)
  end
end
