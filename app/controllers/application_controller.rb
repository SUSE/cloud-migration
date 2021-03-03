class ApplicationController < ActionController::API
  include ExceptionHandler
  include ActionController::Serialization
  # need to include this one as it does not come with API
  include ActionController::MimeResponds

  include ActionController::HttpAuthentication::Basic::ControllerMethods
  http_basic_authenticate_with name: CloudMigration::Application.config.cm_username, password: CloudMigration::Application.config.cm_password

end
