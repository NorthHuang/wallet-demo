# frozen_string_literal: true

class ValidationError < ApiError
  def initialize(error_message = 'Validation failed')
    super(error_message, :bad_request)
  end
end
