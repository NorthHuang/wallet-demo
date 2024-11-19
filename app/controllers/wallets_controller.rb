class WalletsController < ApiController
  def user_balance
    wallet = Wallet.find_by(user_id: @current_user.id).as_api_json
    render json: { success: true, data: wallet }
  end
end
