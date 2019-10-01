module APIv2
  module Entities
    module Mobile
      class FundSource < Base
        expose :id
        expose :currency
        expose :extra
        expose :uid
      end
    end
  end
end