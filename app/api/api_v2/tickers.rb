module APIv2
  class Tickers < Grape::API
    helpers ::APIv2::NamedParams

    desc 'Get ticker of all markets.'
    get "/tickers" do
      Market.all.inject({}) do |h, m|
        h[m.id] = format_ticker Global[m.id].ticker
        h
      end
    end

    desc 'Get ticker of specific market.'
    params do
      use :market
    end
    get "/tickers/:market" do
      format_ticker Global[params[:market]].ticker
    end

    desc 'Get tickers of all markets group wise'
    get "group/tickers" do
      data = Market.all.inject({}) do |h, m|
        h[m.quote_unit] ||= []
        h[m.quote_unit].push Global[m.id].ticker.merge(coin: m.base_unit).delete_if {|key, value| key.eql?(:at) }
        h
      end
      { data: data, success: true }
    end
  end
end
