module Admin
  module Deposits
    class FtoTokensController < CoinsController
      load_and_authorize_resource :class => '::Deposits::FtoToken'
    end

  end
end