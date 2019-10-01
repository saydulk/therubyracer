class Referral < ActiveRecord::Base

  validates_presence_of :name, :level_no
  validates :no_of_referral, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :transaction_bonus, :amount, :numericality => {:greater_than => 0}, allow: nil

  validate :check_referral_no, :future_event

  validates_presence_of :currency, if: proc { |k| k.currency.present? }

  has_many :referral_commissions

  def referral_bonus
    currency = Currency.find(currency) || Currency.find_by_key(ENV['AIRDROP_CURRENCY'])
    "#{amount} #{currency&.currency_name.to_s || ENV['AIRDROP_CURRENCY']}"
  end

  def transection_bonus
    transaction_bonus.present? ? "#{transaction_bonus}%" : "0%"
  end

  def self.active
    active_plan = Referral.find_by_status(true)
    return nil unless active_plan
    (active_plan.date_validity and active_plan.date_validity.past?) ?  nil : active_plan
  end

  private

  def future_event
    if date_validity_choice && date_validity.present?
      errors.add(:date_validity, "Can't be past date!") if date_validity < Time.now
    end
  end

  def check_referral_no
    errors.add(:no_of_referral, "can't be blank!") if no_of_referral_choice && no_of_referral.blank?
  end
end