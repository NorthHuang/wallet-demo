# frozen_string_literal: true

class ConfirmWithdrawalWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :default

  def perform(id)
    return if id.blank?

    withdrawal = Withdrawal.find_by(id: id)
    return if withdrawal.status != 'pending'

    res = check_withdrawal_status&.deep_symbolize_keys

    if  !res[:success] || res[:data][:status] == 'pending'
      ConfirmWithdrawalWorker.perform_in(2.minutes, id)
      return
    end

    if res[:data][:status] == 'success'
      withdrawal.with_lock do
        withdrawal.update!(status: 'success')
        ::Event.create!(
          user_id: withdrawal.user_id,
          eventable: withdrawal,
          event_type: 'withdrawal',
          related_event_id: withdrawal.events.order(created_at: :desc).first.id
        )
      end
      return
    end

    withdrawal.with_lock do
      wallet = Wallet.find_by(user_id: withdrawal.user_id).lock!
      wallet.balance += withdrawal.amount
      wallet.save!
      withdrawal.update!(status: 'failed', metadata: { failed_reason: res[:data][:reason] })
      ::Event.create!(
        user_id: withdrawal.user_id,
        eventable: withdrawal,
        event_type: 'withdrawal',
        related_event_id: withdrawal.events.order(created_at: :desc).first.id
      )
    end
  end

  private
  def check_withdrawal_status
    # TODO add real outside platform check logic
    [{ success: true, data: { status: 'success' } },
     { success: true, data: { status: 'pending' } },
     { success: false },
     { success: true, data: { status: 'failed', reason: 'network error' } },
     { success: true, data: { status: 'failed', reason: 'receiver reject'} },
     { success: true, data: { status: 'failed', reason: 'other errors' } }].sample
  end
end
