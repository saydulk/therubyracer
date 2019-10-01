module Private
  module Deposits
    class EosTokensController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
