# frozen_string_literal: true

class TransferError < ApiError
  def initialize(error_message = 'Transfer operation failed')
    super(error_message, :unprocessable_entity)
  end
end
