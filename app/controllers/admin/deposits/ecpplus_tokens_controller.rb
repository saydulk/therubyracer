module Admin
  module Deposits
    class EcpplusTokensController < CoinsController
      load_and_authorize_resource :class => '::Deposits::EcpplusToken'
    end

  end
end