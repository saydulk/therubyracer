module Private
  module Withdraws
    class ChelscoinsController < ::Private::Withdraws::BaseController
      include ::Withdraws::Withdrawable
    end
  end
end