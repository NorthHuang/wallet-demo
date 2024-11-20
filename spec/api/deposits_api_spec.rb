# spec/requests/deposits_api_spec.rb

require 'rails_helper'

RSpec.describe "Deposits API", type: :request do
  let!(:user) { create(:user) }
  let!(:wallet) { create(:wallet, user: user, balance: 500.0) }
  let!(:secret_key) { Rails.application.secrets.secret_key_base.to_s }
  let!(:valid_token) { JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, secret_key, 'HS256') }
  let!(:valid_headers) { { 'Authorization' => "Bearer #{valid_token}" } }

  describe "GET /deposits" do
    let!(:deposits) { create_list(:deposit, 3, user: user) }

    context "when the user is authenticated" do
      it "returns a list of deposits" do
        get "/deposits", params: { page: 1, per_page: 10 }, headers: valid_headers

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
        expect(json_response['data'].size).to eq(3)
      end
    end

    context "when no token is provided" do
      it "returns an unauthorized error" do
        get "/deposits", params: { page: 1, per_page: 10 }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
      end
    end
  end

  describe "POST /deposits" do
    let(:deposit_params) { { order_no: "ORDER123", platform: "visa", email: user.email, amount: 100.0 } }

    context "when the deposit is successful" do
      before do
        allow_any_instance_of(Deposits::CreateService).to receive(:call).and_return(true)
      end

      it "creates a new deposit" do
        post "/deposits", params: deposit_params

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
      end
    end

    context "when no authentication is required" do
      it "allows the deposit creation without a token" do
        post "/deposits", params: deposit_params

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
      end
    end
  end
end
