# frozen_string_literal: true

module Withdrawals
  class ConfirmService
    def initialize(params)
      @order_no = params[:order_no]
      @platform = params[:platform].to_sym
      @status = params[:status]
      @reason = params[:reason]
    end

    def call
      return if withdrawal.status != 'pending'

      if @status == 'success'
        withdrawal.with_lock do
          withdrawal.update!(status: @status)
          ::Event.create!(
            user_id: withdrawal.user_id,
            eventable: withdrawal,
            event_type: 'withdrawal',
            related_event_id: withdrawal.event.id
          )
        end
        return
      end

      wallet.with_lock do
        withdrawal.lock!
        wallet.balance += withdrawal.amount
        wallet.save!
        withdrawal.update!(status: @status, metadata: { failed_reason: @reason })
        ::Event.create!(
          user_id: withdrawal.user_id,
          eventable: withdrawal,
          event_type: 'withdrawal',
          related_event_id: withdrawal.event.id
        )
      end
    end

    private

    def withdrawal
      @withdrawal ||= Withdrawal.find_by(order_no: @order_no, platform: @platform)
    end

    def wallet
      @wallet ||= Wallet.find_by(user_id: withdrawal.user_id)
    end
  end
end
