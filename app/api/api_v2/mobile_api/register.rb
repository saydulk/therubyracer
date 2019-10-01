module APIv2
  module MobileApi
    class Register < Grape::API

      desc 'Register an account'
      params do
        requires :email, type: String
        requires :password, type: String
        requires :password_confirmation, type: String
        requires :conditions, type: Boolean
        optional :referral, type: String
      end

      post '/register' do
        identity = Identity.new \
          email: params[:email],
          password: params[:password],
          password_confirmation: params[:password_confirmation]

        if identity.valid?
          identity.save
          member = Member.create identity_id: identity.id, email: params[:email]
          ::Authentication.create(provider: 'identity', uid: identity.id, member_id: member.id)
          present token: "Bearer #{member.jwt}", success: true
        else
          present message: identity.errors.full_messages.first, success: false
        end
      end

      desc 'Banners at Home screen'

      get '/banners' do
        banners_ref = [
          { image_link: 'article1.png', url: '/welcome/invite', title: 'Double Referral Rewards' },
          { image_link: 'article5.png', url: '/welcome/activity_sky', title: 'Dev Ops' },
          { image_link: 'article6.png', url: '/welcome/activity_iotx', title: 'IOTX'},
          { image_link: 'article4.png', url: '/welcome/invite', title: 'Dexathon'},
          { image_link: 'article7.png', url: '/welcome/vote', title: 'Community Coins of Month'},
          { image_link: 'article2.png', url: '/welcome/application_form', title: 'INS competition'},
          { image_link: 'article3.png', url: '/welcome/activity_enj2', title: 'Zinance Angles'}
        ]
        present message: banners_ref, success: true
      end

    end
  end
end