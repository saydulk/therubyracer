module Admin
  module Withdraws
    class Aokey7TokensController < CoinsController
      load_and_authorize_resource :class => '::Withdraws::Aokey7Token'

    end
  end
end