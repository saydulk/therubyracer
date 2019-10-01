module Private
  module Deposits
    class TronixesController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
