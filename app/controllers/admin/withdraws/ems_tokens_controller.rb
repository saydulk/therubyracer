module Admin
  module Withdraws
    class EmsTokensController < CoinsController
      load_and_authorize_resource :class => '::Withdraws::EmsToken'

    end

  end
end