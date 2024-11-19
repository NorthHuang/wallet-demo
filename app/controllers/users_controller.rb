class UsersController < ApiController
  skip_before_action :authenticate_request, only: [:login, :register]

  # POST /users/register
  def register
    user = User.new(user_params)
    ActiveRecord::Base.transaction do
      if user.save
        Wallet.create!(user: user, balance: 0.0)

        token = generate_token({ user_id: user.id })
        render json: { message: 'User registered', token: token }, status: :created
      else
        raise ActiveRecord::Rollback
      end
    rescue ActiveRecord::RecordInvalid, ActiveRecord::Rollback
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end


  # POST /users/login
  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = generate_token({ user_id: user.id })
      render json: { success: true, token: token }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  # GET /users/me
  def me
    render json:{ success: true, data: @current_user.as_api_json }
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation, :name)
  end
end
