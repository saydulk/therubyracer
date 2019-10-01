module APIv2
  module Entities
    module Mobile
      class Member < Base

        expose :token do |member, options|
          "Bearer #{ member.jwt }"
        end

        expose :two_factor do |member, options|
          { google: member.enable?, sms: member.sms_enable? }
        end

      end
    end
  end
end