module Admin
  module Withdraws
    class FtoTokensController < CoinsController
      load_and_authorize_resource :class => '::Withdraws::FtoToken'

    end

  end
end