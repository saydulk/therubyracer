module Admin
  module Withdraws
    class EcpplusTokensController < CoinsController
      load_and_authorize_resource :class => '::Withdraws::EcpplusToken'

    end

  end
end