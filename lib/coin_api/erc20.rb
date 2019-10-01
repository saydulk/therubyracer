module CoinAPI
  class ERC20 < ETH

    def contract_address
      currency.contract_address
    end

    def load_balance!
      begin
        PaymentAddress
            .where(currency: currency.code.downcase)
            .where(PaymentAddress.arel_table[:address].is_not_blank)
            .pluck(:address)
            .reject(&:blank?)
            .map do |address|
          data = abi_encode('balanceOf(address)', address)
          json_rpc(:eth_call, [{to: currency.contract_address, data: "0x" + data}, 'latest']).fetch('result').hex.to_d
        end.reduce(&:+).yield_self {|total| total ? total / currency.base_factor : 0.to_d}
      rescue => e
        report_exception_to_screen(e)
        0.0
      end
    end


    # def create_withdrawal!(issuer, recipient, amount, options = {})
    #   permit_transaction(issuer, recipient)
    #   data = abi_encode \
    #     'transfer(address,uint256)',
    #     recipient.fetch(:address),
    #     '0x' + convert_to_base_unit!(amount).to_s(16)
    #
    #   json_rpc(
    #       :eth_sendTransaction,
    #       [{
    #            from: issuer.fetch(:address),
    #            to: contract_address,
    #            data: data
    #        }.compact]
    #   ).fetch('result').yield_self do |txid|
    #     if txid.to_s.match?(/\A0x[A-F0-9]{64}\z/i)
    #       txid
    #     else
    #       raise CoinAPI::Error, "ERC20 withdrawal from #{issuer.fetch(:address)} to #{recipient.fetch(:address)} failed."
    #     end
    #   end
    # end

    def load_deposit!(txid)
      json_rpc(:eth_getTransactionReceipt, [txid]).fetch('result').yield_self do |receipt|

        break unless receipt['status'] == '0x1'

        entries = receipt.fetch('logs').map do |log|
          next unless log.fetch('address').try(:downcase) == contract_address.try(:downcase)
          {amount: convert_from_base_unit(log.fetch('data').hex, currency),
           address: '0x' + log.fetch('topics').last[-40..-1]}
        end

        {id: receipt.fetch('transactionHash'),
         confirmations: latest_block_number - receipt.fetch('blockNumber').hex,
         entries: entries.compact}

      end
    end

    private

    def abi_encode(method, *args)
      '0x' + args.each_with_object(Digest::SHA3.hexdigest(method, 256)[0...8]) do |arg, data|
        data.concat(arg.gsub(/\A0x/, '').rjust(64, '0'))
      end
    end

  end
end
