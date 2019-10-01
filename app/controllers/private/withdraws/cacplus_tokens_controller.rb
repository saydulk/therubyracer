module Private
    module Withdraws
      class CacplusTokensController < ::Private::Withdraws::BaseController
        include ::Withdraws::Withdrawable
      end
    end
  end