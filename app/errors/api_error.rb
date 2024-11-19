# frozen_string_literal: true

class ApiError < StandardError
    attr_reader :status, :error_message

    def initialize(error_message = 'Something went wrong', status = :internal_server_error)
      @error_message = error_message
      @status = status
      super(error_message)
    end
end
