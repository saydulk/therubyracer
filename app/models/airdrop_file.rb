require 'csv'
require 'open-uri'
class AirdropFile < ActiveRecord::Base

  belongs_to :member
  has_one :file_airdrop, class_name: 'Asset::FileAirdrop', as: :attachable
  has_many :airdrop_histories
  has_many :withdraws, through: :airdrop_histories
  accepts_nested_attributes_for :file_airdrop

  paginates_per 10

  def filename
    path = file_airdrop.file.path
    File.basename(path)
  end


  def distribute_token(wallet_user)
    if Rails.env == 'development'
      csv = CSV.parse(File.read(file_airdrop.file.path))
    else
      csv_text = open(file_airdrop.file.url)
      csv = CSV.parse(csv_text)
    end
    csv.each_with_index do |row, index|
      next if index.zero? || row.length != 3
      fs = add_fund_source(row, wallet_user)
      withdraw_params = { fund_source: fs.id, member_id: wallet_user.id , currency: "csc", sum: row[2].to_f}
      withdraw = Withdraws::Chelscoin.new(withdraw_params)
      withdraw.fee = 0
      if withdraw.valid?
        withdraw.save
        withdraw.submit!
        check_limit_withdraw(withdraw)
        AirdropHistory.create(withdraw_id: withdraw.id , airdrop_file_id: id)
      end
    end
    update_column(:is_used, true)
  end

  def add_fund_source(row, wallet_user)
    if (fund_source = FundSource.find_or_initialize_by(uid: row[1])) and fund_source.new_record?
      fund_source.assign_attributes \
        extra: row[0],
        member_id: wallet_user.id,
        currency: 'csc'
      fund_source.save
    end
    fund_source
  end

  private

  def check_limit_withdraw(withdraw)
    limit_token = Currency.find_by_code('csc')
    if (withdraw.sum.to_f <= limit_token.min_deposit_amount.to_f)
      withdraw.reject!
    elsif (withdraw.sum.to_f >= limit_token.quick_withdraw_max.to_f)
      withdraw.reject!
    else
      withdraw.approve!
    end
  end
end
