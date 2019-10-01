module Koin
  class << self
    def base_fiat_ccy
      Currency.first.code
    end 

    def base_fiat_ccy_sym
      base_fiat_ccy.to_sym
    end
  end
end
