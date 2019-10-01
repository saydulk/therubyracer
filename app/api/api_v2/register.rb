module APIv2
  class Register < Grape::API

    desc 'Register an account'

    params do
      requires :email, type: String
      requires :password, type: String
      requires :password_confirmation, type: String
    end

    post '/member/register' do
      identity = Identity.create \
        email: params[:email],
        password: params[:password],
        password_confirmation: params[:password_confirmation]
      member = Member.new identity_id: identity.id, email: params[:email]
      member.save!
      present token: member.jwt
    end
  end
end