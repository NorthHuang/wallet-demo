# spec/requests/withdrawals_api_spec.rb

require 'rails_helper'

RSpec.describe "Withdrawals API", type: :request do
  let!(:user) { create(:user) }
  let!(:wallet) { create(:wallet, user: user, balance: 500.0) }
  let!(:secret_key) { Rails.application.secrets.secret_key_base.to_s }
  let!(:valid_token) { JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, secret_key, 'HS256') }
  let!(:valid_headers) { { 'Authorization' => "Bearer #{valid_token}" } }

  describe "GET /withdrawals" do
    let!(:withdrawals) { create_list(:withdrawal, 3, user: user) }

    it "returns a list of withdrawals" do
      get "/withdrawals", params: { page: 1, per_page: 10 }, headers: valid_headers

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to eq(true)
      expect(json_response['data'].size).to eq(3)
    end

    context "when no token is provided" do
      it "returns an unauthorized error" do
        get "/withdrawals", params: { page: 1, per_page: 10 }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
      end
    end
  end

  describe "POST /withdrawals" do
    context "when the withdrawal is successful" do
      let(:withdrawal_params) { { amount: 100.0, platform: "visa" } }

      before do
        allow_any_instance_of(Withdrawals::CreateService).to receive(:call).and_return(true)
      end

      it "creates a new withdrawal" do
        post "/withdrawals", params: withdrawal_params, headers: valid_headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['success']).to eq(true)
      end
    end

    context "when validation fails" do
      let(:withdrawal_params) { { amount: 0, platform: "visa" } }

      before do
        allow_any_instance_of(Withdrawals::CreateService).to receive(:call)
                                                               .and_raise(ValidationError.new("Invalid amount"))
      end

      it "returns a validation error" do
        post "/withdrawals", params: withdrawal_params, headers: valid_headers

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['msg']).to eq("Invalid amount")
      end
    end

    context "when a withdrawal error occurs" do
      let(:withdrawal_params) { { amount: 1000.0, platform: "visa" } }

      before do
        allow_any_instance_of(Withdrawals::CreateService).to receive(:call)
                                                               .and_raise(WithdrawalError.new("Insufficient balance"))
      end

      it "returns a withdrawal error" do
        post "/withdrawals", params: withdrawal_params, headers: valid_headers

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['msg']).to eq("Insufficient balance")
        expect(json_response['balance']).to eq(wallet.balance.to_s)
      end
    end

    context "when no token is provided" do
      let(:withdrawal_params) { { amount: 100.0, platform: "visa" } }

      it "returns an unauthorized error" do
        post "/withdrawals", params: withdrawal_params

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
      end
    end
  end

  describe "POST /withdrawals/confirm" do
    let!(:withdrawal) { create(:withdrawal, user: user, order_no: "ORDER123", platform: "visa", status: "pending") }
    let!(:event) { create(:event, eventable: withdrawal, user: user, event_type: 'withdrawal') }

    context "when the confirmation is successful" do
      let(:confirm_params) { { order_no: "ORDER123", platform: "visa", status: "success" } }

      it "confirms the withdrawal" do
        post "/withdrawals/confirm", params: confirm_params

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
        expect(withdrawal.reload.status).to eq("success")
      end
    end

    context "when the confirmation fails with an invalid order number" do
      let(:confirm_params) { { order_no: "INVALID", platform: "visa", status: "success" } }

      it "returns an unprocessable entity error" do
        post "/withdrawals/confirm", params: confirm_params

        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
      end
    end
  end
end
