module Admin
  module Deposits
    class TronixesController < CoinsController
      load_and_authorize_resource :class => '::Deposits::Tronix'

    end
  end
end

