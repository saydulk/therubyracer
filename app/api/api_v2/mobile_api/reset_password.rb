module APIv2
  module MobileApi
    class ResetPassword < Grape::API

      desc 'Change Password for loggedIn user'

      params do
        requires :current_password, type: String
        requires :new_password, type: String
        requires :confirm_password, type: String
      end

      post 'password/change' do
        authenticate!
        identity = current_user.identity
        (present success: false, message: get_i18('reset_password','invalid_current_password')  and return) unless identity.authenticate(params[:current_password])
        (present success: false, message: get_i18('reset_password','password_same')  and return) if identity.authenticate(params[:new_password])
        if identity.update_attributes(password: params[:new_password], password_confirmation: params[:confirm_password] )
          present success: true, message: get_i18('reset_password','password_changed')
        else
          present message: identity.errors.full_messages.first, success: false
        end
      end

      desc 'Send forget password token'

      params do
        requires :email, type: String
      end
      post '/forgot_password/send_token' do
        member = Member.find_by_email(params[:email])
        if member
          Token::MobileTokenCode.create member_id: member.id, ip: env['REMOTE_ADDR']
          present success: true
        else
          present success: false, message: get_i18('reset_password','user_no_found')
        end
      end

      desc 'Verify Token Code'

      params do
        requires :token_code, type: String
      end
      get 'forgot_password/verify_token' do
        encoded_token = Token::MobileTokenCode.encode_token params[:token_code]
        if token = Token::MobileTokenCode.where(token: encoded_token, is_used: false).first
          present success: token.update_column(:is_used, true), token: "Bearer #{token.member.jwt}"
        else
          present success: false, message: get_i18('reset_password','token_expired')
        end
      end

      desc 'Reset Password '

      params do
        requires :password, type: String
        requires :confirm_password, type: String
      end
      post '/password/reset' do
        authenticate!
        identity = current_user.identity
        if identity.update_attributes(password: params[:password], password_confirmation: params[:confirm_password])
          present success: true
        else
          present message: identity.errors.full_messages.first, success: false
        end
      end
    end
  end
end