module APIv2
  module MobileApi
    class Profile < Grape::API

      before { authenticate! }

      desc 'Get settings on dashboard'
      get '/settings' do
        present google_auth: current_user.enable?, sms_auth: current_user.sms_enable?, success: true, country_code: current_user.country_dial_code, registered_no: current_user.contact_no_without_country_code
      end

      desc 'To activate and deactivate Google Authentication'
      params do
        requires :password, type: String
        optional :sms_code, type: String
        requires :google_code, type: String
      end
      post 'authenticator/google' do
        identity = current_user.identity
        present success: false, message: get_i18('profile','incorrect')  and return if !identity.authenticate(params[:password])
        (present success: false, message: get_i18('profile','wrong_sms_code')) and return if params[:sms_code].present? && current_user.authenticate_otp(params[:sms_code], drift: 60)
        if current_user.authenticate_otp(params[:google_code], drift: 60)
          current_user.enable? ?  current_user.disable! : current_user.enable!
          present success: true, message: "Google authenticator has been #{current_user.enable? ? 'enabled' : 'disabled'}"
        else
          present success: false, message: get_i18('profile','wrong_google_code')
        end
      end

      desc 'To get 16 provider key.'
      get 'google/secret_key' do
        present secret_key: current_user.otp_secret_key, success: true
      end

      desc 'To register and verify the mobile number with country code'
      params do
        requires :country_code, type: String
        requires :contact_no, type: String
      end
      post 'verify_mobile' do
        id_document = current_user.id_document
        prev_code, pre_contact = [id_document.country_code, id_document.contact_no]
        id_document.assign_attributes(country_code: params[:country_code], contact_no: params[:contact_no])
        if id_document.valid?
          begin
            id_document.save
            TwilioTextMessenger.new("BitCorex- OTP code is - #{current_user.otp_code(time: Time.now + 60)}", current_user.contact_no).call
            present success: true, message: get_i18('profile','sms_sent')
          rescue Exception => e
            id_document.update_attributes(country_code: prev_code, contact_no: pre_contact)
            present success: false, message: get_i18('profile','invalid_number')
          end
        else
          present success: false, message: id_document.errors.full_messages.first.gsub('Contact no', 'Contact no.')
        end
      end

      desc 'Getting countries codes'
      get 'country_codes' do
        present success: true, country_with_codes: CountryCodes::COUNTRY_CODES
      end

      desc 'To activate and deactivate SMS authentication'
      params do
        requires :sms_code, type: String
        optional :google_code, type: String
      end
      post 'authenticator/sms' do
        (present success: false, message: get_i18('profile','wrong_auth_code')) and return if params[:google_code].present? && !current_user.authenticate_otp(params[:google_code], drift: 60)
        if current_user.authenticate_otp(params[:sms_code], drift: 60)
          current_user.sms_enable? ?  current_user.sms_disable! : current_user.sms_enable!
          present success: true, message: "SMS authenticator has been #{current_user.sms_enable? ? 'enabled' : 'disabled'}"
        else
          present success: false, message: get_i18('profile','wrong_sms_code')
        end
      end

    end
  end
end