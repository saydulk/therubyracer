module Private
  module Withdraws
    class EosTokensController < ::Private::Withdraws::BaseController
      include ::Withdraws::Withdrawable
    end
  end
end