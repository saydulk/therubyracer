module Admin
  module Deposits
    class EosTokensController < CoinsController
      load_and_authorize_resource :class => '::Deposits::EosToken'
    end

  end
end