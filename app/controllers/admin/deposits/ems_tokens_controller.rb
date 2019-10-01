module Admin
  module Deposits
    class EmsTokensController < CoinsController
      load_and_authorize_resource :class => '::Deposits::EmsToken'
    end

  end
end