module Private
  module Withdraws
    class UsdcoinsController < ::Private::Withdraws::BaseController
      include ::Withdraws::Withdrawable
    end
  end
end