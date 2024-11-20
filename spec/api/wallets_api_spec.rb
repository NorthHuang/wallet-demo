# spec/requests/wallets_api_spec.rb

require 'rails_helper'

RSpec.describe "Wallets API", type: :request do
  let(:user) { create(:user) }
  let(:wallet) { create(:wallet, user: user, balance: 100.50) }
  let(:secret_key) { Rails.application.secrets.secret_key_base.to_s }
  let(:valid_token) { JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, secret_key, 'HS256') }
  let(:valid_headers) { { 'Authorization' => "Bearer #{valid_token}" } }

  describe "GET /wallets/user_balance" do
    context "when the user has a wallet" do
      before do
        wallet # Ensure wallet is created
      end

      it "returns the user's wallet balance" do
        get "/wallets/user_balance", headers: valid_headers

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
        expect(json_response['data']).to include(
                                           'id' => wallet.id,
                                           'balance' => wallet.balance.to_f, # Decimals are serialized as strings in JSON
                                           'created_at' => wallet.created_at.strftime('%F %T'),
                                           'updated_at' => wallet.updated_at.strftime('%F %T')
                                         )
      end
    end

    context "when no token is provided" do
      it "returns an unauthorized error" do
        get "/wallets/user_balance"

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq("Unauthorized")
      end
    end

    context "when the token is invalid" do
      let(:invalid_headers) { { 'Authorization' => "Bearer invalidtoken" } }

      it "returns an unauthorized error" do
        get "/wallets/user_balance", headers: invalid_headers

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq("Unauthorized")
      end
    end
  end
end
