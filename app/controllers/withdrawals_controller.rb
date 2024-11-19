class WithdrawalsController < ApiController
  skip_before_action :authenticate_request, only: [:confirm]
  def index
    render json: {
      success: true,
      data: ::Withdrawals::IndexService.new(@current_user, index_params).call
    }
  end

  def create
    begin
      ::Withdrawals::CreateService.new(@current_user, create_params).call
      render json: { success: true, data: {} }
    rescue ::ValidationError => e
      Rails.logger.info("Validation failed for user #{@current_user.id}: #{e.error_message}")
      render json: { success: false, msg: e.error_message }, status: e.status
    rescue ::WithdrawalError => e
      Rails.logger.error("Withdrawal error for user #{@current_user.id}: #{e.error_message}")
      render json: { success: false, msg: e.error_message, balance: @current_user.wallet.balance }, status: e.status
    end
  end

  def confirm
    ::Withdrawals::ConfirmService.new(confirm_params).call
    render json: { success: true, data: {} }
  end

  private

  def index_params
    @index_params ||= params.permit(:page, :per_page)
  end

  def create_params
    @create_params ||= params.permit(:amount, :platform)
  end

  def confirm_params
    @confirm_params ||= params.permit(:order_no, :platform, :status, :reason)
  end
end
