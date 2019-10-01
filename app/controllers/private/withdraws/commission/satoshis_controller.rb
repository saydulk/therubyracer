module Private::Withdraws::Commission
  class SatoshisController < ::Private::Withdraws::BaseController
    include ::Withdraws::Withdrawable

    def model_kls
      "withdraws/commission/#{self.controller_name.singularize}".camelize.constantize
    end
  end
end