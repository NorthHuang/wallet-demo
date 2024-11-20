# spec/requests/users_api_spec.rb

require 'rails_helper'

RSpec.describe "Users API", type: :request do
  let(:user) { create(:user) }
  let(:valid_headers) { { 'Authorization' => "Bearer #{valid_token}" } }
  let(:secret_key) { Rails.application.secrets.secret_key_base.to_s }
  let(:valid_token) { JWT.encode({ user_id: user.id, exp: 24.hours.from_now.to_i }, secret_key, 'HS256') }

  describe "POST /users/register" do
    let(:user_params) do
      { name: "New User", email: "newuser@example.com", password: "password" }
    end

    context "when valid parameters are provided" do
      it "creates a new user" do
        post "/users/register", params: user_params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include("message" => "User registered")
      end
    end

    context "when parameters are invalid" do
      let(:invalid_params) { { name: "", email: "invalidemail", password: "123" } }

      it "returns validation errors" do
        post "/users/register", params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("errors")
      end
    end
  end

  describe "POST /users/login" do
    let(:login_params) { { email: user.email, password: "password" } }

    context "when valid credentials are provided" do
      it "logs in the user and returns a token" do
        post "/users/login", params: login_params

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include("token")
      end
    end

    context "when invalid credentials are provided" do
      let(:invalid_params) { { email: user.email, password: "wrongpassword" } }

      it "returns an unauthorized error" do
        post "/users/login", params: invalid_params

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include("error" => "Invalid email or password")
      end
    end
  end

  describe "GET /users/me" do
    context "when a valid token is provided" do
      it "returns the current user's information" do
        get "/users/me", headers: valid_headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']).to include("email" => user.email, "name" => user.name)
      end
    end

    context "when no token is provided" do
      it "returns an unauthorized error" do
        get "/users/me"

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
      end
    end

    context "when an invalid token is provided" do
      let(:invalid_headers) { { 'Authorization' => "Bearer invalidtoken" } }

      it "returns an unauthorized error" do
        get "/users/me", headers: invalid_headers

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include("error" => "Unauthorized")
      end
    end
  end
end
