module Admin
  module Deposits
    class Aokey7TokensController < CoinsController
      load_and_authorize_resource class: '::Deposits::Aokey7Token'
    end
  end
end
