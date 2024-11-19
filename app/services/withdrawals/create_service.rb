# frozen_string_literal: true

module Withdrawals
  class CreateService
    def initialize(user, params)
      @user = user
      @amount = params[:amount].to_f
      @platform = params[:platform].to_sym
    end

    def call
      call_platform

      execute_withdraw
    end

    private

    def call_platform
      # TODO call outside platform api and get order_no
      @order_no = SecureRandom.uuid
    end

    def execute_withdraw
      withdrawal = nil

      wallet.with_lock do
        raise ::WithdrawalError, 'Insufficient balance.' if @amount > wallet.balance
        raise ::ValidationError, 'please input correct amount.' if @amount <= 0

        wallet.balance = wallet.balance - @amount
        wallet.save!
        withdrawal = Withdrawal.create!(
          amount: @amount,
          user_id: @user.id,
          order_no: @order_no,
          platform: @platform,
          status: :pending
        )
        ::Event.create!(
          user_id: @user.id,
          eventable: withdrawal,
          event_type: 'withdrawal'
        )
      end
      ConfirmWithdrawalWorker.perform_in(2.minutes, withdrawal&.id)
    end

    def wallet
      @wallet ||= Wallet.find_by(user_id: @user.id)
    end
  end
end
