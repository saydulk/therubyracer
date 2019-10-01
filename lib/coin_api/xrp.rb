require 'securerandom'
module CoinAPI
  class XRP < BaseAPI
    def initialize(*)
      super
      @json_rpc_call_id = 0
      @json_rpc_endpoint = URI.parse(currency.json_rpc_endpoint)
    end

    def endpoint
      @json_rpc_endpoint
    end

    def to_address(tx)
      normalize_address(tx['Destination'])
    end

    def from_address(tx)
      normalize_address(tx['Account'])
    end

    def load_balance!(address, currency)
      json_rpc(:account_info, [account: normalize_address(address), ledger_index: 'validated', strict: true])
          .fetch('result')
          .fetch('account_data')
          .fetch('Balance')
          .to_d
          .yield_self { |amount| convert_from_base_unit(amount, currency) }
    rescue => e
      report_exception_to_screen(e)
      0.0
    end

    def build_transaction(tx:, currency:)
      {
          id: tx.fetch('hash'),
          entries: build_entries(tx, currency)
      }
    end

    def build_entries(tx, currency)
      [
          {
              amount: convert_from_base_unit(tx.fetch('Amount'), currency)
          }
      ]
    end

    def inspect_address!(address)
      {
          address: normalize_address(address),
          is_valid: valid_address?(normalize_address(address))
      }
    end

    def fetch_transactions(ledger_index)
      json_rpc(
          :ledger,
          [{
               "ledger_index": ledger_index || 'validated',
               "transactions": true,
               "expand": true
           }]
      ).dig('result', 'ledger', 'transactions') || []
    end

    def latest_block_number
      Rails.cache.fetch :latest_ripple_ledger, expires_in: 5.seconds do
        response = json_rpc(:ledger, [{"ledger_index": 'validated'}])
        response.dig('result', 'ledger_index').to_i
      end
    end


    def create_raw_address!(options = {})
      secret = options.fetch(:secret) {Passgen.generate(length: 64, symbols: true)}
      json_rpc(:wallet_propose, {passphrase: secret}).fetch('result')
          .yield_self do |result|
        result.slice('key_type', 'master_seed', 'master_seed_hex',
                     'master_key', 'public_key', 'public_key_hex')
            .merge(address: normalize_address(result.fetch('account_id')), secret: secret)
            .symbolize_keys
      end

    end

    def destination_tag_from(address)
      address =~ /\?dt=(\d*)\Z/
      $1.to_i
    end

    def load_deposit!(txid)
      json_rpc(:tx, [transaction: txid]).fetch('result').yield_self do |tx|
        next unless tx['status'].to_s == 'success'
        #next unless tx['validated']
        next unless valid_address?(normalize_address(tx['Destination'].to_s))
        next unless tx['TransactionType'].to_s == 'Payment'
        #next unless tx.dig('meta', 'TransactionResult').to_s == 'tesSUCCESS'
        #next if tx['DestinationTag'].present?
        next unless String === tx['Amount']
        xrp_val = {id: tx.fetch('hash'),
         confirmations: calculate_confirmations(tx),
         entries: [{amount: convert_from_base_unit(tx.fetch('Amount'), @currency),
                    address: normalize_address(tx['Destination'])}]}
        return xrp_val
      end
    end

    def each_deposit!
      each_batch_of_deposits do |deposits|
        deposits.each {|deposit| yield deposit if block_given?}
      end
    end

    def each_deposit
      each_batch_of_deposits false do |deposits|
        deposits.each {|deposit| yield deposit if block_given?}
      end
    end


    # Returns fee in drops that is enough to process transaction in current ledger
    def calculate_current_fee
      json_rpc(:fee, {}).fetch('result').yield_self do |result|
        result.dig('drops', 'open_ledger_fee')
      end

    end

    #Admin Method
    def xrp_info
      json_rpc(:fetch_info,{clear:'false'}).fetch('result')
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
      body = {
          jsonrpc: '1.0',
          id: @json_rpc_call_id += 1,
          method: method,
          params: [params].flatten
      }.to_json

      headers = {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
      }

      connection.post('/', body, headers).yield_self do |response|
        response.assert_success!.yield_self do |response|

          JSON.parse(response.body).tap do |response|
            response.dig('result', 'error').tap do |error|
              raise Error, error.inspect if error.present?
            end
          end
        end
      end
    end

    def normalize_address(address)
      address.gsub(/\?dt=\d*\Z/, '')
    end

    # def normalize_txid(txid)
    #   txid.downcase
    # end

    def valid_address?(address)
      /\Ar[0-9a-zA-Z]{33}(:?\?dt=[1-9]\d*)?\z/.match?(address)
    end

    def each_batch_of_deposits(raise = true)
      offset = 0
      collected = []

      loop do
        begin
          # Nullify variables before running dangerous code.
          response = nil
          batch_deposits = nil
          response = json_rpc(:tx_history, [start: offset])
          batch_deposits = build_deposit_collection(response.fetch('result').fetch('txs'))
          offset += batch_deposits.count
        rescue => e
          report_exception(e)
          raise e if raise
        end
        collected += batch_deposits if batch_deposits
        yield batch_deposits if batch_deposits
        break if response.blank? || !more_deposits_available?(response)
      end
      collected
    end

    def build_deposit_collection(txs)
      txs.map do |tx|
        next unless tx['TransactionType'].to_s == 'Payment'
        next unless address?(normalize_address(tx['Destination'].to_s))
        next if tx['DestinationTag'].present?
        next unless String === tx['Amount']

        {id: tx.fetch('hash'),
         confirmations: calculate_confirmations(tx),
         entries: [{amount: convert_from_base_unit(tx.fetch('Amount'), @currency),
                    address: normalize_address(tx['Destination'])}]}
      end.compact
    end

    def more_deposits_available?(response)
      response.fetch('result').fetch('txs').present?
    end

    # def calculate_confirmations(tx)
    #   tx.fetch('LastLedgerSequence') { tx.fetch('ledger_index') } - tx.fetch('inLedger')
    # end

    def calculate_confirmations(tx, ledger_index = nil)
      ledger_index ||= tx.fetch('ledger_index')
      latest_block_number - ledger_index
    end

    private

    def generate_destination_tag
      begin
        # Reserve destination 1 for system purpose
        tag = SecureRandom.random_number(10**9) + 2
      end while PaymentAddress.where(currency: :xrp)
                    .where('address LIKE ?', "%dt=#{tag}")
                    .any?
      tag
    end

  end
end
