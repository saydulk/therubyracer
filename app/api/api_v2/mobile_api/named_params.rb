module APIv2
  module MobileApi
    module NamedParams
      extend ::Grape::API::Helpers

      params :auth do
        requires :email, type: String
        requires :password, type: String
      end
    end
  end
end
