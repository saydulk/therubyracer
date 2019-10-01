module Private
  class SettingsController < BaseController
    skip_before_action :auth_member!, only: :send_token_sms

    def index
      unless current_user.activated?
        flash.now[:info] = t('.activated')
      end
    end

    def google_authentication
      if current_user  && current_user.authenticate_otp(params[:settings][:otp_code], drift: 60) && current_user.last_otp != params[:settings][:otp_code]
        # current_user.enable? ? current_user.disable! : current_user.enable!
        if current_user.enable?
          current_user.update_columns(otp_module: 0 , last_change: DateTime.now , last_otp: params[:settings][:otp_code])
          if current_user.sms_disable?
            MemberMailer.disable_google_auth(current_user.id,"google_auth",request.remote_ip).deliver
          end
        else
          current_user.update_columns(otp_module: 1 , last_change: nil , last_otp: params[:settings][:otp_code] )
        end
        redirect_to settings_path, notice: t('private.settings.sms_authentication.notice', type: 'Google' ,status: (current_user.enable? ? 'activated' : 'deactivated') )
      else
        redirect_to settings_path, alert: t('private.settings.sms_authentication.wrong_otp')
      end
    end

    def sms_authentication
      if current_user && current_user.authenticate_otp(params[:settings][:otp_code], drift: 60) && current_user.last_otp != params[:settings][:otp_code]
        if current_user.sms_enable?
          current_user.update_columns(sms_auth: 0, contact_no: nil, country_code: nil,last_change: DateTime.now, last_otp: params[:settings][:otp_code])
          if current_user.disable?
            MemberMailer.disable_google_auth(current_user.id,"sms_auth",request.remote_ip).deliver
          end
        else
          current_user.update_columns(sms_auth: 1, contact_no: params[:settings][:contact_no], country_code: params[:settings][:country_code],last_change: nil, last_otp: params[:settings][:otp_code])
        end
        redirect_to settings_path, notice: t('.notice', type: 'SMS' ,status: (current_user.sms_enable? ? 'activated' : 'deactivated'))
      else
        redirect_to settings_path, alert: t('.wrong_otp')
      end
    end

    def send_token_sms
      member = Member.find_by_id(params[:member]) || current_user
      if member.sms_enable?
        contact_no = member.contact_no
      else
        member.id_document.update_attributes(country_code: params[:code], contact_no: params[:to]) if params[:to].present? && params[:code].present?
        contact_no = member&.contact_no
      end
      domain_url = "#{ENV.fetch('URL_SCHEME', 'http')}://#{ENV['URL_HOST']}"
      TwilioTextMessenger.new( t('.sms_text', token: member.otp_code(time: Time.now + 60), domain: domain_url ), contact_no).call if contact_no.present?
    rescue Exception => e
      @sms_status = e.message
    end

  end
end