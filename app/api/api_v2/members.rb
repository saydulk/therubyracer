module APIv2
  class Members < Grape::API
    helpers APIv2::NamedParams

    before { authenticate! }

    desc 'Get your profile and accounts info.', scopes: %w[ profile ]
    get '/members/me' do
      present current_user, with: APIv2::Entities::Member
    end

    desc 'Get Account details'
    params do
      requires :currency, type: String, values: ::Currency.all.map(&:code), desc: "Currency must be any one of #{::Currency.all.map(&:code).join(', ')}"
    end

    get '/account' do
      account = current_user.accounts.find_by_currency(params[:currency])
      present account, with: APIv2::Entities::Mobile::Account, user: current_user
    end

  end
end
