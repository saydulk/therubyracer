module Admin
  class AirdropsController < BaseController

    before_filter :get_wallet_balance, only: :index
    before_action :find_airdrop_file, only: %w(destroy send_token airdrop_history)

    def index
      @airdrop = AirdropFile.new
      @airdrop_all = AirdropFile.order('created_at desc').page(params[:page])
    end


    def create
      begin
        airdrop = current_user.airdrop_files.new(airdrop_params)
        if CsvCheckerService.new(airdrop.file_airdrop, true).is_valid? and airdrop.valid?
          if airdrop.save
            airdrop.update_columns(original_name: params[:airdrop_file][:file_airdrop_attributes][:file].try(:original_filename))
          end
          flash[:notice] = 'File uploaded Successfully'
        else
          Rails.logger.warn { "airdrop.file_airdrop ==> #{airdrop.file_airdrop.inspect}" }
          flash[:alert] = 'Invalid file type.please make sure your file format is valid!'
        end
        redirect_to action: :index
      rescue Exception => e
        Rails.logger.warn { "airdrop.file_airdrop ==> #{e.backtrace.inspect}" }
        flash[:alert] = 'Invalid file type.please make sure your file format is valid!'
        redirect_to action: :index
      end

    end

    def destroy
      @airdrop.destroy
      redirect_to admin_airdrops_path
    end

    def send_token
      otp_verify = current_user.authenticate_otp(params[:otp_code].to_s, drift: 60)
      if otp_verify
        wallet_user = Member.find_by_email(ENV['AIRDROP_USER'])
        @airdrop.distribute_token(wallet_user)
      end
      render json: { otp_verify: otp_verify }
    end

    def airdrop_history
      @airdrop_history = @airdrop.withdraws.page(params[:page])
    end

    def download_pdf
      send_file "#{Rails.root}/public/airdrop.csv", type: "application/csv", x_sendfile: true
    end

    private

    def airdrop_params
      params.require(:airdrop_file).permit({file_airdrop_attributes: %i(id file)})
    end

    def get_wallet_balance
      account = Account.joins(:member)
                    .with_currency('csc')
                    .where("members.email = ?",ENV['AIRDROP_USER']).first
      @avail_balance = account.nil? ? 0.0 : account.balance.to_f
    end


    def find_airdrop_file
      @airdrop = AirdropFile.find(params[:id])
    end
  end
end