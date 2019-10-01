module Private
  module Deposits
    class EmsTokensController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
