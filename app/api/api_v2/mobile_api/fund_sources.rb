module APIv2
  module MobileApi
    class FundSources < Grape::API

      before { authenticate! }

      desc 'To get fund sources(Address listing for a specific currency)'
      params do
        requires :currency
      end
      get '/fund_sources' do
        fund_sources = current_user.fund_sources.where(currency: params[:currency])
        present fund_sources, with: APIv2::Entities::Mobile::FundSource
      end

      desc 'To create fund sources(Address listing for a specific currency)'
      params do
        requires :currency
        requires :extra
        requires :uid
      end
      post '/fund_source' do
        fund_source = current_user.fund_sources.create(currency: params[:currency], extra: params[:extra], uid: params[:uid])
        present fund_source, with: APIv2::Entities::Mobile::FundSource
      end

      desc 'To update fund source(Address listing for a specific currency)'
      params do
        requires :id
        requires :currency
        requires :extra
        requires :uid
      end
      patch '/fund_source' do
        fund_source = current_user.fund_sources.find_by_id(params[:id])
        fund_source.update_attributes(currency: params[:currency], extra: params[:extra], uid: params[:uid])
        present fund_source, with: APIv2::Entities::Mobile::FundSource
      end

      desc 'To delete fund sources(Address listing for a specific currency)'
      delete '/fund_source/:id' do
        fund_source = current_user.fund_sources.find_by_id(params[:id])
        if fund_source.present?
          fund_source.destroy
          present message: 'ok', success: true
        else
          present message: 'invalid fund source', success: false
        end
      end

    end
  end
end