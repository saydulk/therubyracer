require 'query_param_helper.rb'
require 'faraday'
require 'json'


module Cryptocompare
  module Price
  	PRICE_API_URL = 'https://min-api.cryptocompare.com/data/pricemulti'
		PRICE_FULL_API_URL = 'https://min-api.cryptocompare.com/data/pricemultifull'
  	def self.find(from_syms, to_syms, flag = false)
  		params = {
  			'from_syms' => Array(from_syms).join(','),
  			'to_syms'  => Array(to_syms).join(',')
  		}
			path = flag  ? PRICE_API_URL : PRICE_FULL_API_URL
  		full_path = QueryParamHelper.set_query_params(path, params)
  		api_resp = Faraday.get(full_path)
  		data = JSON.parse(api_resp.body)

			return { "#{from_syms}" => { "#{to_syms}" => 0.5 } } if data.has_key?('Response') && from_syms.eql?(ENV['AIRDROP_CURRENCY'])
			return { "#{from_syms}" => { "#{to_syms}" => 0.0 } } if data.has_key? 'Response'

			flag ? data :  data['DISPLAY'].dig(from_syms, to_syms, 'PRICE')
  	end
  end
end




















