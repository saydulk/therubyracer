module Admin
    module Withdraws
      class CacplusTokensController < CoinsController
        load_and_authorize_resource :class => '::Withdraws::CacplusToken'
  
      end
  
    end
  end