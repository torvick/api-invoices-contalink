module ApiResponder
  extend ActiveSupport::Concern

  def render_success(data: {}, meta: nil, status: :ok)
    payload = { status: "success", data: data }
    payload[:meta] = meta if meta
    render json: payload, status: status
  end

  def render_error(code:, message:, status: :bad_request, errors: nil)
    payload = { status: "error", error: { code: code, message: message } }
    payload[:error][:details] = errors if errors
    render json: payload, status: status
  end
end
