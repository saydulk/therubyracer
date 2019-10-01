module Private
  module Withdraws
    class ImpereumsController < ::Private::Withdraws::BaseController
      include ::Withdraws::Withdrawable
    end
  end
end