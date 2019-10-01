module Private
  module Withdraws
    class EthereumsController < ::Private::Withdraws::BaseController
      include ::Withdraws::Withdrawable
    end
  end
end