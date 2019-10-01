module Private
  module Withdraws
    class EmsTokensController < ::Private::Withdraws::BaseController
      include ::Withdraws::Withdrawable
    end
  end
end