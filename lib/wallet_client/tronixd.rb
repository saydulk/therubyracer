# encoding: UTF-8
# frozen_string_literal: true

module WalletClient
  class Tronixd < Base

    def initialize(*)
      super
      @json_rpc_endpoint = URI.parse(wallet.uri)
    end


    def create_withdrawal!(issuer, recipient, amount, options = {})
      response = json_rpc(
          "wallet/createtransaction", {"owner_address": normalize_address(issuer.fetch(:address)), "to_address": normalize_address(recipient.fetch(:address)), amount: amount}
      )
      if response.has_key? 'txID'
        response.fetch('txID').yield_self { |txid| normalize_txid(txid) }
      else
        raise WalletClient::Error, \
          "#{response['Error']}"
      end
    end

    def load_balance!(address, currency)
      json_rpc("wallet/getaccount",{"address": address}).fetch('balance').to_d
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
      response['Error'].tap { |error| raise Error, error.inspect if error }
      response
    end
  end
end
