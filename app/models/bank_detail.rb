class BankDetail < ActiveRecord::Base
  extend Enumerize
  include AASM
  include AASM::Locking

  belongs_to :member
  validates_uniqueness_of :account_number
  validates_presence_of :name, :bank_name, :account_number, :ifsc_code
  validates :account_number, format: { with: /\A\d+\z/ }

  scope :is_verified, -> (status) { where(aasm_state: status) }

  STATES = %i(unverified verifying verified)

  enumerize :aasm_state, in: STATES, scope: true

  aasm do
    state :unverified, initial: true
    state :verifying
    state :verified

    event :submit do
      transitions from: :unverified, to: :verifying
    end

    event :approve do
      transitions from: [:unverified, :verifying],  to: :verified
    end

    event :reject do
      transitions from: [:verifying, :verified],  to: :unverified
    end
  end
end
