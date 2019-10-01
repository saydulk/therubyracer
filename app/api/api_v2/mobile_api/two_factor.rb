module APIv2
  module MobileApi
    class TwoFactor < Grape::API

      desc 'Two factor authentication APIs'
      params do
        requires :auth_type, type: String
        requires :otp_code, type: String
      end
      get '/two_factor' do
        authenticate!
        if current_user
          if %w(mobile google).include?(params[:auth_type])
            if (params[:auth_type].eql?('google') && current_user.enable?) || (params[:auth_type].eql?('mobile') && current_user.sms_enable?)
              if current_user.authenticate_otp(params[:otp_code], drift: 60)
                present message: get_i18('two_factor','otp_matched'), success: true
              else
                present message: get_i18('two_factor','otp_no_matched'), success: false
              end
            else
              present message: "#{params[:auth_type].capitalize} two factor is not activated", success: false
            end
          else
            present message: get_i18('two_factor','invalid_two_factor') , success: false
          end
        else
          present message: get_i18('two_factor','invalid_authorization'), success: false
        end
      end

      desc 'Send sms on registered mobile number'
      get '/sms/otp_code' do
        begin
          authenticate!
          contact_no = current_user.contact_no
          TwilioTextMessenger.new( get_i18('two_factor','otp_msg', token: "#{current_user.otp_code(time: Time.now + 60)}") , contact_no).call if contact_no.present? && current_user.sms_enable?
          present success: true, message: get_i18('two_factor','otp_sent')
        rescue Exception => e
          present success: false, message: e.message
        end
      end
    end
  end
end