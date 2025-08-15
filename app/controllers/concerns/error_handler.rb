module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActionController::ParameterMissing, with: :render_missing_param
    rescue_from ActiveRecord::RecordNotFound,       with: :render_not_found
    rescue_from ActionController::UnknownFormat,    with: :render_unknown_format
    rescue_from ActionController::RoutingError,     with: :render_route_not_found
    rescue_from AbstractController::ActionNotFound, with: :render_route_not_found
    rescue_from ArgumentError, Date::Error,         with: :render_invalid_params
  end

  private

  def render_missing_param(e)
    render_error(code: "missing_params", message: e.param.to_s, status: :bad_request)
  end

  def render_not_found(_e = nil)
    render_error(code: "not_found", message: "resource_not_found", status: :not_found)
  end

  def render_unknown_format(_e = nil)
    render_error(code: "not_acceptable", message: "unsupported_format", status: :not_acceptable)
  end

  def render_route_not_found(_e = nil)
    render_error(code: "route_not_found", message: "path_not_found", status: :not_found)
  end

  def render_invalid_params(e)
    render_error(code: "invalid_params", message: e.message, status: :unprocessable_content)
  end
end
