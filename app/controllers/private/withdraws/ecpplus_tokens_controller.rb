module Private
  module Withdraws
    class EcpplusTokensController < ::Private::Withdraws::BaseController
      include ::Withdraws::Withdrawable
    end
  end
end