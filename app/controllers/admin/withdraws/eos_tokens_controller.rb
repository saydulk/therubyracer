module Admin
  module Withdraws
    class EosTokensController < CoinsController
      load_and_authorize_resource :class => '::Withdraws::EosToken'

    end

  end
end