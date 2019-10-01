module Admin
  module Withdraws
    class TronixesController < CoinsController
      load_and_authorize_resource :class => '::Withdraws::Tronix'

    end
  end
end