# frozen_string_literal: true
module Transfers
  class CreateService
    def initialize(user, params)
      @user = user
      @to_user_id = params[:to_user_id].to_i
      @amount = params[:amount].to_f
    end

    def call
      validate_params
      transfer_with_lock
    end

    private
    def validate_params
      raise ::ValidationError, 'Can not transfer to yourself.' if @to_user_id == @user.id
      raise ::ValidationError, 'please input correct amount.' if @amount <= 0
    end

    def transfer_with_lock
      if user_wallet.id < to_user_wallet.id
        user_wallet.with_lock do
          to_user_wallet.lock!
          execute_transfer
        end
      else
        to_user_wallet.with_lock do
          user_wallet.lock!
          execute_transfer
        end
      end
    end

    def execute_transfer
      raise ::TransferError, 'Insufficient balance.' if @amount > user_wallet.balance

      user_wallet.balance = user_wallet.balance - @amount
      to_user_wallet.balance = to_user_wallet.balance + @amount
      user_wallet.save!
      to_user_wallet.save!
      transfer = ::Transfer.create!(
        amount: @amount, from_user_id: @user.id, to_user_id: @to_user_id
      )
      transfer_out_event = ::Event.create!(
        user_id: @user.id,
        eventable: transfer,
        event_type: 'transfer_out'
      )
      transfer_in_event = ::Event.create!(
        user_id: @to_user_id,
        eventable: transfer,
        event_type: 'transfer_in',
        related_event_id: transfer_out_event.id
      )
      transfer_out_event.update!(related_event_id: transfer_in_event.id)
    end

    def user_wallet
      @user_wallet ||= ::Wallet.find_by(user_id: @user.id)
    end

    def to_user_wallet
      @to_user_wallet ||= ::Wallet.find_by(user_id: @to_user_id)
    end
  end
end
