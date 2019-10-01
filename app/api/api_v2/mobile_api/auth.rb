module APIv2
  module MobileApi
    class Auth < Grape::API

      namespace  do

        before { verify_devise! }

        desc 'Login account'
        params do
          requires :email, type: String
          requires :password, type: String
          requires :devise_id, type: String
          requires :devise_type, type: String
        end

        post '/auth' do
          member = Member.find_by_email(params[:email])
          if member
            identity = member.identity
            if identity && identity.authenticate(params[:password])
              bearer_token = "Bearer #{member.jwt}"
              BlacklistToken.create(token: bearer_token, devise_id: params[:devise_id], devise_type: params[:devise_type], email: member.email, in_use: true)
              present token: bearer_token, success: true, two_factor: {google: member.enable?, sms: member.sms_enable?}

              # present member, with: APIv2::Entities::Mobile::Member
            else
              present success: false, message: get_i18('auth','wrong_email')
            end
          else
            present success: false, message: get_i18('auth','wrong_email')
          end
        end

        namespace do
          before { authenticate! }

          get '/logout' do
            BlacklistToken.find_or_create_by(token: headers['Authorization'])&.update_column(:in_use, false)
            present message: get_i18('auth','token_expie'), success: true
          end
        end
      end
    end
  end
end