module CoinAPI
  class TRX < BaseAPI

    def initialize(*)
      super
      @json_rpc_call_id = 0
      @json_rpc_endpoint = URI.parse(currency.json_rpc_endpoint)
    end


    def latest_block_number
      Rails.cache.fetch :latest_tronix_block_number, expires_in: 5.seconds do
        json_rpc("wallet/getnowblock", {}).dig('block_header', 'raw_data', 'number')
      end
    end


    def get_block(height)
      current_block = height || 0
      json_rpc('wallet/getblockbynum', {num: current_block})
    end

    def to_address(tx)
      tx.dig('raw_data','contract').map{|v| v['parameter']['value']['to_address'] if v['parameter']['value'].has_key?('to_address')}.compact
    end

    def build_transaction(tx, current_block_json, address)
      entries = tx.dig('raw_data', 'contract').map do |item|
        next if item.dig('parameter', 'value', 'amount').to_d <= 0
        next unless item.dig('parameter', 'value').has_key?('to_address')
        next if address != normalize_address(item.dig('parameter', 'value', 'to_address'))
        { amount: (item.dig('parameter', 'value', 'amount').to_d)/currency.base_factor, address: normalize_address( item['parameter'].dig('value','to_address')) }
      end.compact
      { id:             tx.fetch('txID'),
        block_number:   current_block_json.dig('block_header', 'raw_data', 'number'),
        entries:       entries }
    end

    def create_address!(account)
      json_rpc('wallet/generateaddress',["value": account])
        .yield_self do |response|
        {
          legacy_address: response.fetch('address'),
          address: response.fetch('hexAddress'),
          secret: response.fetch('privateKey')
        }
      end
    end

    def load_deposit!(txid)
      json_rpc("wallet/gettransactionbyid", {"value": txid}).yield_self do |tx|
        return if tx.blank?
        block_number  = get_block_by_txid(txid).fetch('blockNumber')
        amount_val =  tx.dig('raw_data','contract').map{|v|v['parameter']['value']['amount']}.join(',')
        address_val =  tx.dig('raw_data','contract').map{|v|v['parameter']['value']['to_address']}.join(',')
        {id: tx.fetch('txID'),
         confirmations: latest_block_number - block_number,
         received_at: Time.at(tx.dig('raw_data','timestamp')),
         entries: [{amount: convert_from_base_unit(amount_val.to_d, @currency), address: address_val }]
        }
      end
    end

    def inspect_address!(address)
      json_rpc("wallet/validateaddress", {"address": address}).yield_self do |x|
        {address: address,
         is_valid: x.fetch('result'),
         is_mine: :unsupported}
      end
      end

    protected

    def connection
      Faraday.new(@json_rpc_endpoint).tap do |connection|
        unless @json_rpc_endpoint.user.blank?
          connection.basic_auth(@json_rpc_endpoint.user, @json_rpc_endpoint.password)
        end
      end
    end

    memoize :connection

    def json_rpc(method, params = {})
      response = connection.post \
        "/#{method}",
        params.to_json,
        {'Accept' => 'application/json',
         'Content-Type' => 'application/json'}
      response.assert_success!
      response = JSON.parse(response.body)
      response['error'].tap { |error| raise Error, error.inspect if error }
      response
    end

    def get_block_by_txid(id)
      json_rpc("wallet/gettransactioninfobyid", {"value": id})

    end
  end
end
