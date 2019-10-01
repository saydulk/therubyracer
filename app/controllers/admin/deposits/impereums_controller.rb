module Admin
  module Deposits
    class ImpereumsController < CoinsController
      load_and_authorize_resource :class => '::Deposits::Impereum'
    end

  end
end