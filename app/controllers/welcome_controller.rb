class WelcomeController < ApplicationController
  layout 'landing'

  def index
    @market = Market.first
    @markets = Market.all.sort
    @market_groups = @markets.map(&:quote_unit).uniq

    if params[:ref] && !current_user
      cookies[:ref] = { value: params[:ref], :expires => 1.hour.from_now, path: 'signup'}
      redirect_to root_path
    end
  end
end
