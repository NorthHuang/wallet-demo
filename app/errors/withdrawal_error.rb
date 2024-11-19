# frozen_string_literal: true

class WithdrawalError < ApiError
  def initialize(error_message = 'Withdrawal operation failed')
    super(error_message, :unprocessable_entity)
  end
end
