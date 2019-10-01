module CoinAPI
  class BTC < BaseAPI
    def initialize(*)
      super
        @json_rpc_endpoint = URI.parse(currency.json_rpc_endpoint)
    end

    def load_balance!
      json_rpc(:getbalance).fetch('result').to_d
    end

    def each_deposit!
      each_batch_of_deposits do |deposits|
        deposits.each {|deposit| yield deposit}
      end
    end

    def each_deposit
      each_batch_of_deposits false do |deposits|
        deposits.each {|deposit| yield deposit}
      end
    end

    def load_deposit!(txid)
      json_rpc(:gettransaction, [txid]).fetch('result').yield_self {|tx| build_standalone_deposit(tx)}
    end

    def create_address!(account)
      {address: json_rpc(:getnewaddress,[account]).fetch('result')}
    end

    def create_withdrawal!(issuer, recipient, amount, options = {})
      json_rpc(:settxfee, [options[:fee]]) if options.key?(:fee)
      json_rpc(:sendtoaddress, [recipient.fetch(:address), amount]).fetch('result')
    end

    def latest_block_number
      Rails.cache.fetch "latest_#{self.class.name.underscore}_block_number", expires_in: 5.seconds do
        json_rpc(:getblockcount).fetch('result')
      end
    end

    def get_block(block_hash)
      json_rpc(:getblock, [block_hash, 2]).fetch('result')
    end

    def get_block_hash(height)
      current_block   = height || 0
      json_rpc(:getblockhash, [current_block]).fetch('result')
    end

    def inspect_address!(address)
      json_rpc(:validateaddress, [address]).fetch('result').yield_self do |x|
        {address: address,
         is_valid: !!x['isvalid'],
         is_mine: !!x['ismine'] || PaymentAddress.where(currency: currency.id, address: address).exists?}
      end
    end


    def to_address(tx)
      tx.fetch('vout').map{|v| normalize_address(v['scriptPubKey']['addresses'][0]) if v['scriptPubKey'].has_key?('addresses')}.compact
    end

    def build_transaction(tx, current_block, address)
      entries = tx.fetch('vout').map do |item|

        next if item.fetch('value').to_d <= 0
        next unless item['scriptPubKey'].has_key?('addresses')
        next if address != normalize_address(item['scriptPubKey']['addresses'][0])

        { amount: item.fetch('value').to_d, address: normalize_address(item['scriptPubKey']['addresses'][0]) }
      end.compact

      { id:            normalize_txid(tx.fetch('txid')),
        block_number:  current_block,
        entries:       entries }
    end


    def get_unconfirmed_txns
      json_rpc(:getrawmempool).fetch('result').map(&method(:get_raw_transaction))
    end

    def get_raw_transaction(txid)
      json_rpc(:getrawtransaction, [txid, true]).fetch('result')
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

    def json_rpc(method, params = [])
      response = connection.post \
        '/',
        {jsonrpc: "2.0", method: method, params: params}.to_json,
        {'Accept' => 'application/json',
         'Content-Type' => 'application/json'}
      response.assert_success!
      response = JSON.parse(response.body)
      response['error'].tap {|error| raise Error, error.inspect if error}
      response
    end

    def each_batch_of_deposits(raise = true)
      offset = 0
      collected = []
      loop do
        begin
          batch_deposits = nil
          response = json_rpc(:listtransactions, ['*', 100, offset])
          offset += 100
          batch_deposits = build_deposit_collection(response.fetch('result'))
        rescue => e
          report_exception(e)
          raise e if raise
        end
        yield batch_deposits if batch_deposits
        break if batch_deposits.empty?
      end
      collected
    end

    def build_standalone_deposit(tx)
      entries = tx.fetch('details').map do |item|
        next unless item.fetch('category') == 'receive'
        {amount: item.fetch('amount').to_d, address: item.fetch('address')}
      end.compact
      {id: tx.fetch('txid'),
       confirmations: tx.fetch('confirmations').to_i,
       received_at: Time.at(tx.fetch('timereceived')),
       entries: entries}
    end

    def build_deposit_collection(txs)
      txs.map do |tx|
        next unless tx.fetch('category') == 'receive'
        {id: tx.fetch('txid'),
         confirmations: tx.fetch('confirmations').to_i,
         received_at: Time.at(tx.fetch('timereceived')),
         entries: [{amount: tx.fetch('amount').to_d, address: tx.fetch('address')}]}
      end.compact
    end
  end
end
