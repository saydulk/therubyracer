module Admin
  module Withdraws
    class UsdcoinsController < CoinsController
      load_and_authorize_resource :class => '::Withdraws::Usdcoin'

    end

  end
end