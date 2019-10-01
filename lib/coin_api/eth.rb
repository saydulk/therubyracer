module CoinAPI
  class ETH < BaseAPI
    TOKEN_EVENT_IDENTIFIER = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef'
    SUCCESS = '0x1'

    def initialize(*)
      super
      @json_rpc_call_id = 0
      @json_rpc_endpoint = URI.parse(currency.json_rpc_endpoint)
    end

    def create_address!(account)
      Passgen.generate(length: 64, symbols: true).yield_self do |password|
        {address: json_rpc(:personal_newAccount, [password]).fetch('result'), secret: password}
      end
    end

    # def load_balance!
    #   begin
    #     PaymentAddress
    #         .where(currency: currency.code.downcase)
    #         .where(PaymentAddress.arel_table[:address].is_not_blank)
    #         .pluck(:address)
    #         .reject(&:blank?)
    #         .map do |address|
    #       json_rpc(:eth_getBalance, [address, 'latest']).fetch('result').hex.to_d
    #     end.reduce(&:+).yield_self {|total| total ? total / currency.base_factor : 0.to_d}
    #   rescue => e
    #     report_exception_to_screen(e)
    #     0.0
    #   end
    # end

    def load_balance!(address, currency)
      if currency.eth?
        amount = json_rpc(:eth_getBalance, [normalize_address(address), 'latest'])
            .fetch('result')
            .hex
            .to_d
        convert_from_base_unit(amount, currency)
      else
        load_balance_of_address(address, currency)
      end
    end

    def load_balance_of_address(address, currency)
      data = abi_encode('balanceOf(address)', normalize_address(address))
      json_rpc(:eth_call, [{ to: contract_address(currency), data: data }, 'latest'])
          .fetch('result')
          .hex
          .to_d
          .yield_self { |amount| convert_from_base_unit(amount, currency) }
    end


    def inspect_address!(address)
      {address: address,
       is_valid: /\A0x[A-F0-9]{40}\z/i.match?(address),
       is_mine: :unsupported}
    end

    def get_block(height)
      current_block   = height || 0
      json_rpc(:eth_getBlockByNumber, ["0x#{current_block.to_s(16)}", true]).fetch('result')
    end

    def to_address(tx)
      if tx.has_key?('logs')
        get_erc20_addresses(tx)
      else
        [tx.fetch('to')]
      end.compact
    end

    def get_erc20_addresses(tx)
      tx.fetch('logs').map do |log|
        next if log.fetch('topics').blank? || log.fetch('topics')[0] != TOKEN_EVENT_IDENTIFIER
        '0x' + log.fetch('topics').last[-40..-1]
      end
    end


    # def create_withdrawal!(issuer, recipient, amount, options = {})
    #   permit_transaction(issuer, recipient)
    #
    #   json_rpc(
    #       :eth_sendTransaction,
    #       [{
    #            from: issuer.fetch(:address),
    #            to: recipient.fetch(:address),
    #            value: '0x' + convert_to_base_unit!(amount).to_s(16),
    #            gas: options.key?(:gas_limit) ? '0x' + options[:gas_limit].to_s(16) : nil
    #        }.compact]
    #   ).fetch('result').yield_self do |txid|
    #     if txid.to_s.match?(/\A0x[A-F0-9]{64}\z/i)
    #       txid
    #     else
    #       raise CoinAPI::Error, "ETH withdrawal from #{issuer.fetch(:address)} to #{recipient.fetch(:address)} failed."
    #     end
    #   end
    # end

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

    def load_deposit!(txid)
      json_rpc(:eth_getTransactionByHash, [txid]).fetch('result').yield_self do |tx|
        return if tx.blank?
        block = block_information(tx.fetch('blockNumber'))
        {id: tx.fetch('hash'),
         confirmations: latest_block_number - tx.fetch('blockNumber').hex,
         received_at: Time.at(block.fetch('timestamp').hex),
         entries: [{amount: tx.fetch('value').hex.to_d / currency.base_factor,
                    address: tx.fetch('to')}]}
      end
    end

    def build_transaction(txn, current_block_json, currency)
      if txn.has_key?('logs')
        build_erc20_transaction(txn, current_block_json, currency)
      else
        build_eth_transaction(txn, current_block_json, currency)
      end
    end

    def invalid_eth_transaction?(block_txn)
      block_txn.fetch('to').blank? \
      || block_txn.fetch('value').hex.to_d <= 0 && block_txn.fetch('input').hex <= 0 \
    end

    def invalid_erc20_transaction?(txn_receipt)
      # txn_receipt.fetch('status') != SUCCESS \
      # || txn_receipt.fetch('to').blank? \       \\ ABOVE CODE FOR GETH RELATED CODE AND BELOW PARITY....
      # || txn_receipt.fetch('logs').blank?

      txn_receipt.fetch('status') != SUCCESS \
      || txn_receipt.fetch('logs').blank?
    end

    def get_txn_receipt(txid)
       json_rpc(:eth_getTransactionReceipt, [txid]).fetch('result')
    end

    def latest_block_number
      Rails.cache.fetch :latest_ethereum_block_number, expires_in: 5.seconds do
        json_rpc(:eth_blockNumber).fetch('result').hex
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

    def json_rpc(method, params = [])
      response = connection.post \
        '/',
        {jsonrpc: '2.0', id: @json_rpc_call_id += 1, method: method, params: params}.to_json,
        {'Accept' => 'application/json',
         'Content-Type' => 'application/json'}
      response.assert_success!
      response = JSON.parse(response.body)
      response['error'].tap {|error| raise Error, error.inspect if error}
      response
    end

    # https://ethereum.stackexchange.com/questions/25389/getting-transaction-history-for-a-particular-account
    # https://github.com/ethereum/go-ethereum/issues/2104#issuecomment-168748944
    # https://github.com/ethereum/web3.js/issues/580
    def each_batch_of_deposits(raise = true)
      collected = []
      latest_block_n = latest_block_number
      current_block_n = latest_block_n
      latest_block = nil
      current_block = nil

      while current_block_n > 0
        begin
          batch_deposits = nil
          block = json_rpc(:eth_getBlockByNumber, ["0x#{current_block_n.to_s(16)}", true]).fetch('result')
          current_block = block
          latest_block = block if latest_block_n == current_block_n
          batch_deposits = build_deposit_collection(block.fetch('transactions'), current_block, latest_block)
        rescue => e
          report_exception(e)
          raise e if raise
        end
        yield batch_deposits if batch_deposits && block_given?
        collected += batch_deposits
        current_block_n -= 1
      end

      collected
    end

    def build_deposit_collection(txs, current_block, latest_block)
      txs.map do |tx|
        next if tx.fetch('to').blank? || tx.fetch('value').hex.to_d <= 0
        {id: tx.fetch('hash'),
         confirmations: latest_block.fetch('number').hex - current_block.fetch('number').hex,
         received_at: Time.at(current_block.fetch('timestamp').hex),
         entries: [{amount: tx.fetch('value').hex.to_d / currency.base_factor,
                    address: tx.fetch('to')}]}
      end.compact
    end

    # def latest_block_number
    #   json_rpc(:eth_blockNumber).fetch('result').hex
    # end

    def block_information(number)
      json_rpc(:eth_getBlockByNumber, [number, false]).fetch('result')
    end

    def permit_transaction(issuer, recipient)
      json_rpc(:personal_unlockAccount, [issuer.fetch(:address), issuer.fetch(:secret), 5]).tap do |response|
        unless response.fetch('result')
          raise CoinAPI::Error, "ETH withdrawal from #{issuer.fetch(:address)} to #{recipient.fetch(:address)} failed."
        end
      end
    end

    #Returns the client coinbase address. http://localhost:8545
    def eth_coinbase
      do_request(:eth_coinbase)
    end

    def do_request(method, *params)
      response = connection.post(
          '/',
          json_rpc_params(method, *params).to_json,
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
      )

      response.assert_success!
      response = JSON.parse(response.body)
      response['error'].tap {|error| raise Error, error.inspect if error}
      response.fetch('result')
    end

    def build_eth_transaction(tx, current_block_json, currency)
      { id:            tx.fetch('hash'),
        block_number:  current_block_json.fetch('number').hex,
        entries:       currency.eql?('eth') ? build_entries(tx, currency) : [] }
    end

    def build_entries(tx, currency)

      [
          { amount:  convert_from_base_unit(tx.fetch('value').hex, currency),
            address: tx['to']}
      ]
    end

    def build_erc20_transaction(tx, current_block_json, currency)
      entries = tx.fetch('logs').map do |log|

        next if log.fetch('topics').blank? || log.fetch('topics')[0] != TOKEN_EVENT_IDENTIFIER
        # Skip if ERC20 contract address doesn't match.
        #next if tx.fetch('to') != currency.contract_address

        { amount:  convert_from_base_unit(log.fetch('data').hex, currency),
          address: '0x' + log.fetch('topics').last[-40..-1] }
      end

      { id:            tx.fetch('transactionHash'),
        block_number: current_block_json.fetch('number').hex,
        entries:       entries.compact }
    end

    def json_rpc_params(method, *params)
      {
          jsonrpc: '2.0',
          method: method,
          params: params,
          id: increment_request_id!
      }
    end

    def increment_request_id!
      self.request_id += 1
    end

    def formatter
      Formatter.new(currency)
    end

    memoize :formatter
  end
end
