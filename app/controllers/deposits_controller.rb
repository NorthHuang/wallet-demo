class DepositsController < ApiController
  skip_before_action :authenticate_request, only: [:create]
  def index
    render json: {
      success: true,
      data: ::Deposits::IndexService.new(@current_user, index_params).call
    }
  end

  def create
    ::Deposits::CreateService.new(create_params).call
    render json: { success: true, data: {} }
  end

  private

  def index_params
    @index_params ||= params.permit(:page, :per_page)
  end

  def create_params
    @create_params ||= params.permit(:order_no, :platform, :email, :amount)
  end
end
