module Admin
  module Deposits
    class FiatsController < ::Admin::Deposits::BaseController
      load_and_authorize_resource :class => '::Deposits::Fiat'

      def index
        respond_to do |format|
          format.html
          format.json { render json: FiatDepositDatatable.new(params) }
        end
      end

      def show
        @fiat_deposit = "::Deposits::Fiat".constantize.find(params[:id])
      end
    end
  end
end

