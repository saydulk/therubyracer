module Admin
    module Deposits
      class CacplusTokensController < CoinsController
        load_and_authorize_resource :class => '::Deposits::CacplusToken'
      end
  
    end
  end