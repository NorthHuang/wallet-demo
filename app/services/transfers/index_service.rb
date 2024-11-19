# frozen_string_literal: true
module Transfers
  class IndexService
    TYPE = %w[all in out].freeze

    def initialize(user, params)
      @user = user
      @type = params[:type] || 'all'
      @page = params[:page] || 1
      @per = params[:per] || 10
    end

    def call
      return [] unless @type.in?(TYPE)

      send(@type)
    end

    private
    def all
      Transfer.includes(:from_user, :to_user).where(
        'from_user_id = ? or to_user_id = ?',
        @user.id,
        @user.id
      ).page(@page).per(@per).map { |e| e.as_all_api_json(@user.id) }
    end

    def in
      @user.transfer_ins.includes(:from_user).page(@page).per(@per).map(&:as_in_api_json)
    end

    def out
      @user.transfer_outs.includes(:to_user).page(@page).per(@per).map(&:as_out_api_json)
    end
  end
end

