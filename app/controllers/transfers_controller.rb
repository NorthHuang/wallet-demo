class TransfersController < ApiController
  def index
    render json: {
      success: true,
      data: ::Transfers::IndexService.new(@current_user, index_params).call
    }
  end

  def create
    begin
      ::Transfers::CreateService.new(@current_user, create_params).call
      render json: { success: true }
    rescue ::ValidationError => e
      Rails.logger.info("Validation failed for user #{@current_user.id}: #{e.error_message}")
      render json: { success: false, msg: e.error_message }, status: e.status
    rescue ::TransferError => e
      Rails.logger.error("Transfer error for user #{@current_user.id}: #{e.error_message}")
      render json: { success: false, msg: e.error_message, balance: @current_user.wallet.balance }, status: e.status
    end
  end

  private

  def index_params
    @index_params ||= params.permit(:page, :per_page, :type)
  end

  def create_params
    @create_params ||= params.permit(:to_user_id, :amount)
  end
end
