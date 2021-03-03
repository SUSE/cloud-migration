module ExceptionHandler
  extend ActiveSupport::Concern

  ERROR_MAP = {
    ActiveRecord::RecordNotFound => {
      method: :record_not_found,
      status: :not_found
    },
    ActionController::ParameterMissing => {
      method: :parameter_missing,
      status: :unprocessable_entity
    },
    ActiveRecord::RecordInvalid => {
      method: :record_invalid,
      status: :unprocessable_entity
    },
    AbstractController::ActionNotFound => {
      method: :record_not_found,
      status: :not_found
    },
    ActionController::RoutingError => {
      method: :route_not_found,
      status: :not_found
    }
  }.freeze

  included do
    rescue_from StandardError do |e|
      logger.error(e.message)
      handle_error(e)
    end
  end

  private

  def handle_error(e)
    if ERROR_MAP.keys.include? e.class
      handler = ERROR_MAP[e.class]
      body = send(handler[:method], e)
      status = handler[:status]
    else
      body = {
        message: e.message
      }
      status = e.status
    end

    render json: body, status: status
  end

  # Define the return bodies here, per error type

  def route_not_found(e)
    {
      message: "Route not found",
      details: e.message
    }
  end

  def record_not_found(e)
    {
      message: "Not found",
      details: e.message
    }
  end

  def parameter_missing(e)
    {
      message: "Parameter missing",
      details: e.message,
      parameter: e.param
    }
  end

  def record_invalid(e)
    {
      model: e.record.class.name,
      attributes: e.record.errors.messages.keys,
      message: "Invalid record",
      details: e.record.errors.messages
    }
  end
end

