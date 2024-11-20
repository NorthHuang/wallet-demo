# spec/requests/transfers_api_spec.rb

require 'rails_helper'

RSpec.describe "Transfers API", type: :request do
  let!(:user) { create(:user) }
  let!(:to_user) { create(:user) }
  let!(:wallet) { create(:wallet, user: user, balance: 500.0) }
  let!(:secret_key) { Rails.application.secrets.secret_key_base.to_s }
  let!(:valid_token) { JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, secret_key, 'HS256') }
  let!(:valid_headers) { { 'Authorization' => "Bearer #{valid_token}" } }

  describe "GET /transfers" do
    let!(:transfers) { create_list(:transfer, 3, from_user: user, to_user: to_user) }

    it "returns a list of transfers" do
      get "/transfers", params: { page: 1, per_page: 10 }, headers: valid_headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to eq(true)
      expect(json_response['data'].size).to eq(3)
    end

    context "when no token is provided" do
      it "returns an unauthorized error" do
        get "/transfers", params: { page: 1, per_page: 10 }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
      end
    end
  end

  describe "POST /transfers" do
    context "when the transfer is successful" do
      let(:transfer_params) { { to_user_id: to_user.id, amount: 100.0 } }

      before do
        allow_any_instance_of(Transfers::CreateService).to receive(:call).and_return(true)
      end

      it "creates a new transfer" do
        post "/transfers", params: transfer_params, headers: valid_headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['success']).to eq(true)
      end
    end

    context "when validation fails" do
      let(:transfer_params) { { to_user_id: nil, amount: 100.0 } }

      before do
        allow_any_instance_of(Transfers::CreateService).to receive(:call)
                                                             .and_raise(ValidationError.new("Invalid user ID"))
      end

      it "returns a validation error" do
        post "/transfers", params: transfer_params, headers: valid_headers

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['msg']).to eq("Invalid user ID")
      end
    end

    context "when a transfer error occurs" do
      let(:transfer_params) { { to_user_id: to_user.id, amount: 1000.0 } }

      before do
        allow_any_instance_of(Transfers::CreateService).to receive(:call)
                                                             .and_raise(TransferError.new("Insufficient balance"))
      end

      it "returns a transfer error" do
        post "/transfers", params: transfer_params, headers: valid_headers

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['msg']).to eq("Insufficient balance")
        expect(json_response['balance']).to eq(wallet.balance.to_s)
      end
    end

    context "when no token is provided" do
      let(:transfer_params) { { to_user_id: to_user.id, amount: 100.0 } }

      it "returns an unauthorized error" do
        post "/transfers", params: transfer_params

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
      end
    end
  end
end
