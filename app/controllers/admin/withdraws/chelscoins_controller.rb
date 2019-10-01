module Admin
  module Withdraws
    class ChelscoinsController < CoinsController
      load_and_authorize_resource :class => '::Withdraws::Chelscoin'

    end

  end
end