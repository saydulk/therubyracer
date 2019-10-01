module Admin
  module Deposits
    class ChelscoinsController < CoinsController
      load_and_authorize_resource :class => '::Deposits::Chelscoin'
    end

  end
end