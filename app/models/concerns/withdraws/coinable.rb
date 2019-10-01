module Withdraws
  module Coinable
    extend ActiveSupport::Concern

    def blockchain_url
      currency_obj.address_blockchain_url(fund_uid) if currency_obj.present?
    end

    def audit!
      puts"==========audit!==#{fund_uid.inspect}=="
      inspection = CoinAPI[currency].inspect_address!(fund_uid)
      puts"=============inspection=====#{inspection.inspect}============"
      if inspection[:is_valid] == false
        puts"==========if====false"
        Rails.logger.info "#{self.class.name}##{id} uses invalid address: #{fund_uid.inspect}"
        reject
        save!
      else
        puts"====else=="
        super
      end
    end

    def as_json(options={})
      super(options).merge({
        blockchain_url: blockchain_url
      })
    end

    def amount_to_base_unit!
      currency = Currency.find_by_code(self.currency)
      x = amount.to_d * currency.base_factor
      unless (x % 1).zero?
        raise CoinAPI::Error, "Failed to convert value to base (smallest) unit because it exceeds the maximum precision: "  "#{amount.to_d} - #{x.to_d} must be equal to zero."
      end
      x.to_i
    end

  end
end

