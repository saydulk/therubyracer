# encoding: UTF-8
# frozen_string_literal: true

module WalletClient
  class Geth < Base

    def initialize(*)
      super
      @json_rpc_call_id  = 0
      @json_rpc_endpoint = URI.parse(wallet.uri)
    end


    def create_eth_withdrawal!(issuer, recipient, amount, options = {})
      permit_transaction(issuer, recipient)
      fetch_nonce = get_nonce(issuer)
      address_nonce = AddressNonce.find_by(address: normalize_address(issuer[:address]))
      nonce = address_nonce&.nonce
      if (nonce.present? && nonce.to_i > 0)
        nonce_val = (fetch_nonce.hex > nonce.to_i) ? fetch_nonce.hex : nonce.to_i + 1
      else
        nonce_val = fetch_nonce.hex
      end
      Rails.logger.info "nonce before withdraw==========> #{nonce_val.inspect}"
      json_rpc(
          :eth_sendTransaction,
          [{
               from:     normalize_address(issuer.fetch(:address)),
               to:       normalize_address(recipient.fetch(:address)),
               value:    '0x' + amount.to_i.to_s(16),
               gas:      options.key?(:gas_limit) ? '0x' + options[:gas_limit].to_i.to_s(16) : nil,
               gasPrice: options.key?(:gas_price) ? '0x' + options[:gas_price].to_i.to_s(16) : nil,
               nonce: nonce_val ? '0x' + nonce_val.to_i.to_s(16) : nil
           }.compact]
      ).fetch('result').yield_self do |txid|
        raise WalletClient::Error, \
          "#{wallet.name} withdrawal from #{normalize_address(issuer[:address])} to #{normalize_address(recipient[:address])} failed." \
            unless valid_txid?(normalize_txid(txid))
        # update nonce value in DB
        if address_nonce
          address_nonce.update_columns(nonce: nonce_val)
        else
          AddressNonce.create(address: normalize_address(issuer[:address]), nonce: nonce_val)
        end
        #  return txid
        normalize_txid(txid)
      end
    end

    def create_erc20_withdrawal!(issuer, recipient, amount, options = {})
      permit_transaction(issuer, recipient)
      fetch_nonce = get_nonce(issuer)
      address_nonce = AddressNonce.find_by(address: normalize_address(issuer[:address]))
      nonce =  address_nonce&.nonce
      if (nonce.present? && nonce.to_i > 0)
        nonce_val = (fetch_nonce.hex > nonce.to_i) ? fetch_nonce.hex : nonce.to_i + 1
      else
        nonce_val = fetch_nonce.hex
      end
      Rails.logger.info "nonce before withdraw ======> #{nonce_val.inspect}"

      data = abi_encode \
        'transfer(address,uint256)',
        normalize_address(recipient.fetch(:address)),
        '0x' + amount.to_s(16)

      Rails.logger.info "create_erc20_withdrawal!  ==> data => #{data.inspect}"
      Rails.logger.info "create_erc20_withdrawal! options => #{options.inspect}"
      Rails.logger.info "create_erc20_withdrawal!  ==> issuer => #{issuer}"

      json_rpc(
          :eth_sendTransaction,
          [{
               from: normalize_address(issuer.fetch(:address)),
               to:   options[:contract_address],
               data: data,
               gas: options.key?(:gas_limit) ? '0x' + options[:gas_limit].to_i.to_s(16) : nil,
               gasPrice: options.key?(:gas_price) ? '0x' + options[:gas_price].to_i.to_s(16) : nil,
               nonce: nonce_val ? '0x' + nonce_val.to_i.to_s(16) : nil
           }]
      ).fetch('result').yield_self do |txid|
        raise WalletClient::Error, \
          "#{wallet.name} withdrawal from #{normalize_address(issuer[:address])} to #{normalize_address(recipient[:address])} failed." \
            unless valid_txid?(normalize_txid(txid))
        # update nonce value in DB
        if address_nonce
          address_nonce.update_columns(nonce: nonce_val)
        else
          AddressNonce.create(address: normalize_address(issuer[:address]), nonce: nonce_val)
        end
        #  return txid
        normalize_txid(txid)
      end
    end

    def permit_transaction(issuer, recipient)
      json_rpc(:personal_unlockAccount, [normalize_address(issuer.fetch(:address)), issuer.fetch(:secret), 5]).tap do |response|
        unless response['result']
          raise WalletClient::Error, \
            "#{wallet.name} withdrawal from #{normalize_address(issuer[:address])} to #{normalize_address(recipient[:address])} is not permitted."
        end
      end
    end


    def normalize_address(address)
      address.downcase
    end

    def normalize_txid(txid)
      txid.downcase
    end

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
      json_rpc(:eth_call, [{ to: erc20_contract_address(currency), data: data }, 'latest'])
          .fetch('result')
          .hex
          .to_d
          .yield_self { |amount| convert_from_base_unit(amount, currency) }
    end

    def eth_fees_for_erc20(erc20_amount)
      json_rpc(:eth_estimateGas, [{amount: erc20_amount.to_s}])
          .fetch('result')
          .hex
    end

    def get_txn_receipt(txid)
      json_rpc(:eth_getTransactionReceipt, [txid]).fetch('result')
    end

    protected

    def abi_encode(method, *args)
      '0x' + args.each_with_object(Digest::SHA3.hexdigest(method, 256)[0...8]) do |arg, data|
        data.concat(arg.gsub(/\A0x/, '').rjust(64, '0'))
      end
    end

    def abi_explode(data)
      data = data.gsub(/\A0x/, '')
      { method:    '0x' + data[0...8],
        arguments: data[8..-1].chars.in_groups_of(64, false).map { |group| '0x' + group.join } }
    end

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
        { jsonrpc: '2.0', id: @json_rpc_call_id += 1, method: method, params: params }.to_json,
        { 'Accept'       => 'application/json',
          'Content-Type' => 'application/json' }
      response.assert_success!
      response = JSON.parse(response.body)
      response['error'].tap { |error| raise Error, error.inspect if error }
      response
    end

    def erc20_contract_address(currency)
      currency_val = Currency.find_by_code(currency)
      normalize_address(currency_val.contract_address)
    end


    def valid_txid?(txid)
      txid.to_s.match?(/\A0x[A-F0-9]{64}\z/i)
    end

    def get_nonce(issuer)
      json_rpc(:eth_getTransactionCount, [normalize_address(issuer.fetch(:address)), "pending"]).fetch('result')
    end
  end
end
