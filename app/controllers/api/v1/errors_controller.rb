class Api::V1::ErrorsController < ApplicationController
  def not_found
    render_error(code: "route_not_found",
                 message: "The path #{request.path} does not exist",
                 status: :not_found)
  end

  def method_not_allowed
    render_error(code: "method_not_allowed",
                 message: "Method #{request.request_method} not allowed for #{request.path}",
                 status: :method_not_allowed)
  end
end
