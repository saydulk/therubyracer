module Private
  class BankDetailsController < BaseController
    before_action :find_bank, only: %i(show edit update destroy)

    def index
      @bank = current_user.bank_details
    end

    def new
      @bank = BankDetail.new
    end

    def create
      @bank = current_user.bank_details.new(bank_params)
      if @bank.save
        redirect_to bank_details_path
      else
        render 'new'
      end
    end

    def update
      if params[:ajax]
        result = @bank.update(active: true)
        render json: result
      else
        if @bank.update(bank_params)
          redirect_to bank_details_path
        else
          render 'edit'
        end
      end

    end

    def destroy
      @bank.destroy
      redirect_to bank_details_path
    end

    private

    def bank_params
      params.require(:bank_detail).permit(:name, :bank_name, :account_number, :ifsc_code, :active, :state, :member_id)
    end

    def find_bank
      @bank = BankDetail.find(params[:id])
    end
  end
end
