module Private
  module Deposits
    class EcpplusTokensController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
