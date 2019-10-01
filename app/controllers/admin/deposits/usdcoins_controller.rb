module Admin
  module Deposits
    class UsdcoinsController < CoinsController
      load_and_authorize_resource :class => '::Deposits::Usdcoin'
    end

  end
end