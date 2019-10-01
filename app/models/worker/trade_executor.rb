module Worker
  class TradeExecutor

    def process(payload)
      payload.symbolize_keys!
      ::Matching::Executor.new(payload).execute! if payload[:volume].to_f > 0 
    rescue
      raise $!
    end

  end
end
