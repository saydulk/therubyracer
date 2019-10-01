module APIv2
  module MobileApi
    module Helpers

      def get_withdraw(params)
        model_klass = model_kls(params[:currency])
        object = model_klass.new(
          member_id: current_user.id,
          fund_source: fund_source_by_address(current_user, params[:address], params[:currency]),
          currency: params[:currency],
          sum: params[:sum],
          payment_id: params[:payment_id]
        )
        return object
      rescue
        Rails.logger.info "Failed to create withdraw: #{$!}"
        Rails.logger.debug object.inspect
        Rails.logger.debug $!.backtrace.join("\n")
        raise WithDrawError, $!
      end

      private

      def model_kls(currency)
        channel = WithdrawChannel.find_by_currency(currency)
        "withdraws/#{channel.key}".camelize.constantize
      end

      def fund_source_by_address(user, address, currency)
        fund_source = user.fund_sources.find_or_initialize_by(uid: address, currency: currency)
        if fund_source.new_record?
          fund_source.extra = random_name
          fund_source.save
        end
        fund_source.id
      end

      def random_name
        (0...15).map { ('a'..'z').to_a[rand(26)] }.join
      end
    end
  end
end
