module Admin
  module Withdraws
    class ImpereumsController < CoinsController
      load_and_authorize_resource :class => '::Withdraws::Impereum'

    end

  end
end