module Private::Withdraws
  class TronixesController < ::Private::Withdraws::BaseController
    include ::Withdraws::Withdrawable
  end
end
