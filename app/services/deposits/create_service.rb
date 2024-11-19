# frozen_string_literal: true

module Deposits
  class CreateService
    def initialize(params)
      @order_no = params[:order_no]
      @platform = params[:platform].to_sym
      @amount = params[:amount].to_f
      @email = params[:email]
    end

    def call
      wallet.with_lock do
        wallet.balance += @amount
        wallet.save!

        deposit = Deposit.create!(
          user_id: user.id,
          amount: @amount,
          platform: @platform,
          order_no: @order_no
        )

        ::Event.create!(
          user_id: user.id,
          eventable: deposit,
          event_type: 'deposit'
        )
      end
    end

    private
    def user
      @user ||= User.find_by(email: @email)
    end

    def wallet
      @wallet ||= Wallet.find_by(user_id: user.id)
    end
  end
end
