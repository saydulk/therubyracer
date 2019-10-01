require_dependency 'admin/deposits/base_controller'
module Admin
  module Deposits
    class CoinsController < BaseController
      before_action :set_data_csv , only: [:csv_deposit]
      def index
        params['self'] = self
        # @deposits = deposit_model.includes(:member)
        #                 .where('created_at > ?', 1.year.ago)
        #                 .order(created_at: :desc)
        #                 .page(params[:page])
        #                 .per(20)
        respond_to do |format|
          format.html
          format.json { render json: DepositsAdminDatatable.new(params) }
        end
      end

      def csv_deposit
        fname = 'deposit'
        @csv_data = set_data_csv.includes(:member)
                .where('created_at > ?', 1.year.ago)
                .order(id: :desc)
        send_data Deposit.export(@csv_data),
                  :type => 'text/csv; charset=iso-8859-1; header=present',
                  :disposition => "attachment; filename=#{fname}.csv"
      end

      def update
        deposit = deposit_model.find(params[:id])
        deposit.accept! if deposit.may_accept?
        redirect_to :back, notice: t('admin.deposits.coins.update.notice')
      end

      private

       def deposit_model
         "::Deposits::#{self.class.name.demodulize.gsub(/Controller\z/, '').singularize}".constantize
       end

      def set_data_csv
        controller_name =  params[:controller_name].split('/').last
        controller_name = (controller_name.include?'_') ?  (controller_name.split('_').map{|x| x.capitalize}.join()) : controller_name.capitalize
        "::Deposits::#{controller_name.singularize}".constantize
      end

      helper_method :deposit_model

    end
  end
end