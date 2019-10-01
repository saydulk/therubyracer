module Private
    module Deposits
      class CacplusTokensController < ::Private::Deposits::BaseController
        include ::Deposits::CtrlCoinable
      end
    end
  end
  