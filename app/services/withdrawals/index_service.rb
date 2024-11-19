# frozen_string_literal: true

module Withdrawals
  class IndexService
    def initialize(user, params)
      @user = user
      @page = params[:page] || 1
      @per = params[:per] || 10
    end

    def call
      @user.withdrawals.page(@page).per(@per).map(&:as_api_json)
    end
  end
end
