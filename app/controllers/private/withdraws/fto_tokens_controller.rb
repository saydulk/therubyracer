module Private
  module Withdraws
    class FtoTokensController < ::Private::Withdraws::BaseController
      include ::Withdraws::Withdrawable
    end
  end
end