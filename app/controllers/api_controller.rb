class ApiController < ActionController::API
  before_action :authenticate_request
  rescue_from ApiError, with: :render_application_error

  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s

  # Decode JWT token
  def authenticate_request
    token = request.headers['Authorization']&.split(' ')&.last
    decoded_token = decode_token(token)
    @current_user = User.find(decoded_token[:user_id]) if decoded_token
  rescue JWT::DecodeError
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  # Generate JWT token
  def generate_token(payload)
    payload[:exp] = 24.hours.from_now.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  private

  def decode_token(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })
    decoded[0].symbolize_keys
  end

  def render_application_error(error)
    render json: { success: false, msg: error.error_message }, status: error.status
  end
end
