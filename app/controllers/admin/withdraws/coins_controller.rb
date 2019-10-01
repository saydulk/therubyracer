require_dependency 'admin/withdraws/base_controller'
module Admin
  module Withdraws
    class CoinsController < BaseController
      before_action :find_withdraw, only: [:show, :update, :destroy]
      before_action :set_data_csv, only: [:csv_withdraw]

      def index
        params['self'] = self
        @latest_withdraws  = withdraw_model.where('created_at > ?', 1.day.ago).order(created_at: :desc)
        @all_withdraws     = withdraw_model.all.order(created_at: :desc)
        respond_to do |format|
          format.html
          format.json { render json: AdminWithdrawDatatable.new(params) }
        end
      end

      def show
      end

      def update
        @withdraw.transaction do
          @withdraw.approve!
        end
        redirect_to :back, notice: t('admin.withdraws.coins.update.notice')
      end

      def destroy
        reject = @withdraw.reject!
        redirect_to "#{request.url}?reject=#{reject}" , notice: t('admin.withdraws.coins.update.notice')
      end


      def withdraw_rejected_mail
        @id = params[:withdraw_id]
        WithdrawMailer.withdraw_state(@id, params[:send_text]).deliver
        redirect_to :back
      end

      def csv_withdraw
          fname = 'withdraw'
          data  = set_data_csv.where('created_at > ?', 1.day.ago).order(id: :desc) if params[:type] == 'one_day'
          data  = set_data_csv.all.order(id: :desc) if params[:type] == 'full'
          send_data Withdraw.export(data),
                    :type => 'text/csv; charset=iso-8859-1; header=present',
                    :disposition => "attachment; filename=#{fname}.csv"
      end

      private

      def withdraw_model
        "::Withdraws::#{self.class.name.demodulize.gsub(/Controller\z/, '').singularize}".constantize
      end

      def set_data_csv
        controller_name =  params[:controller_name].split('/').last
        controller_name = (controller_name.include?'_') ?  (controller_name.split('_').map{|x| x.capitalize}.join()) : controller_name.capitalize
        "::Withdraws::#{controller_name.singularize}".constantize
      end

      helper_method :withdraw_model
    end
  end
end