Rails.application.configure do
  config.lograge.enabled = Rails.env.production? || ENV['OPENPROJECT_LOGRAGE_ENABLED']
  config.lograge.base_controller_class = %w[ActionController::Base]

  config.lograge.ignore_actions = ['AlertsController#get_pop_up_alerts']

  # Add custom data to event payload
  config.lograge.custom_payload do |controller|
    ::OpenProject::Logging::LogDelegator.controller_payload_hash controller
  end
end
