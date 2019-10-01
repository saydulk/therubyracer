require 'csv'
class Currency < ActiveYamlBase
  include International
  include ActiveHash::Associations

  field :visible, default: true

  self.singleton_class.send :alias_method, :all_with_invisible, :all

  def self.all
    all_with_invisible.select &:visible
  end

  def self.enumerize
    all_with_invisible.inject({}) {|memo, i| memo[i.code.to_sym] = i.id; memo}
  end

  def self.codes
    @keys ||= all.map &:code
  end

  def self.export(data)
    attributes = %w(Name Locked Balance Sum Hot-Wallet-Balance Cold-Wallet-Balance)
    csv_data = CSV.generate do |csv|
      csv <<  attributes
      if data.present?
        data.each do |val|
          row_data = []
          row_data << val[:name]
          row_data << val[:locked].round(6)
          row_data << val[:balance].round(6)
          row_data << val[:sum].round(6)
          if val[:coinable]
            row_data << val[:hot]
            if val[:hot] == 'N/A' || val[:hot].is_a?(Hash)
              row_data << 'N/A'
            elsif val[:sum] - val[:hot] < 0
              row_data << '0.0'
            else
              row_data << val[:sum] - val[:hot]
            end
          else
            row_data << 'N/A'
            row_data << 'N/A'
          end
          csv << row_data
        end
      end
    end
    return csv_data
  end

  def self.ids
    @ids ||= all.map &:id
  end

  def self.assets(code)
    find_by_code(code)[:assets]
  end

  def self.coins
    @coins ||= Currency.where(coin: true)
  end

  def self.fiats
    @fiats ||= Currency.where(coin: false)
  end

  def self.coin_codes
    @coin_codes ||= self.coins.map(&:code)
  end

  def self.coin_name(code)
    Currency.find_by_code(code)&.currency_name
  end

  def precision
    self[:precision]
  end

  def api
    raise unless coin?
    # CoinRPC[code]
    CoinAPI[code]
  end

  def fiat?
    not coin?
  end

  def balance_cache_key
    "peatio:hotwallet:#{code}:balance"
  end

  def balance
    Rails.cache.read(balance_cache_key) || 0
  end

  def decimal_digit
    self.try(:default_decimal_digit) || (fiat? ? 2 : 4)
  end

  def refresh_balance
    # Rails.cache.write(balance_cache_key, api.safe_getbalance) if coin?
    # Rails.cache.write(balance_cache_key, api.balance || 'N/A') if coin?
    Rails.cache.write(balance_cache_key, api.load_balance || 'N/A') if coin?
  end

  def blockchain_url(txid)
    raise unless coin?
    blockchain.gsub('#{txid}', txid.to_s)
  end

  def address_blockchain_url(fund_uid)
    raise unless coin?
    address_url(fund_uid)
  end

  def address_url(address)
    raise unless coin?
    self[:address_url].try :gsub, '#{address}', address
  end

  def quick_withdraw_max
    @quick_withdraw_max ||= BigDecimal.new self[:quick_withdraw_max].to_s
  end

  # Allows to dynamically check value of code:
  #
  #   code.btc? # true if code equals to "btc".
  #   code.xrp? # true if code equals to "xrp".
  #
  def code
    self[:code]&.inquiry
  end

  def as_json(options = {})
    {
        key: key,
        code: code,
        coin: coin,
        blockchain: blockchain,
        quick_withdraw_max: quick_withdraw_max,
        quick_withdraw_min: quick_withdraw_min
    }
  end

  def summary
    locked = Account.locked_sum(code)
    balance = Account.balance_sum(code)
    sum = locked + balance
    coinable = self.coin?
    # hot = coinable ? self.balance : nil
    hot = coinable ? balance : nil

    {
        name: self.code.upcase,
        sum: sum,
        balance: balance,
        locked: locked,
        coinable: coinable,
        hot: hot
    }
  end

  def summary_24
    locked = Account.locked_sum_24(code)
    balance = Account.balance_sum_24(code)
    sum = locked + balance
    coinable = self.coin?
    # hot = coinable ? self.balance : nil
    hot = coinable ? balance : nil

    {
        name: self.code.upcase,
        sum: sum,
        balance: balance,
        locked: locked,
        coinable: coinable,
        hot: hot
    }
  end

  def key_text
    code.upcase
  end

  def code_text
    code.upcase
  end

  def name_text
    code.upcase
  end

  def type
    fiat? ? :fiat : :coin
  end

  def is_erc20?
    self.contract_address.present?
  end
end