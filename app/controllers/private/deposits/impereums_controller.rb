module Private
  module Deposits
    class ImpereumsController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
