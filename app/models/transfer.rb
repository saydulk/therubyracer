class Transfer < ActiveRecord::Base
  STATES = %i[submitted canceled rejected accepted].freeze
  include AASM
  include AASM::Locking
  include Currencible


  validates :wallet_address,    presence: true
  validates :cold_wallet_address, presence: true

  aasm whiny_transitions: false do
    state :submitted, initial: true
    state :canceled
    state :rejected
    state :accepted
    state :processing
    state :done
    state :failed
    state :confirming
    event(:cancel) { transitions from: :submitted, to: :canceled }
    event(:reject) { transitions from: :submitted, to: :rejected }
    event :accept do
      transitions from: :submitted, to: :accepted
    end
    event :process do
      transitions from: :accepted, to: :processing
    end
    event :dispatch do
      # TODO: add validations that txid and block_number are not blank.
      transitions from: :processing, to: :confirming
    end
    event :succeed do
      transitions from: :confirming, to: :done

      # before [:set_txid, :unlock_and_sub_funds]
    end

    event :fail do
      transitions from: %i[processing confirming], to: :failed
      #after :unlock_funds
    end
  end

  def audit_transfer!
    with_lock do
        accept
        process
      save!
    end

    # FIXME: Unfortunately AASM doesn't fire after_commit
    # callback (don't be confused with ActiveRecord's after_commit).
    # This probably was broken after upgrade of Rails & gems.
    # The fix is to manually invoke #send_coins! and #send_email.
    # NOTE: These calls should be out of transaction so fast workers
    # would not start processing data before it was committed to DB.
    AMQPQueue.enqueue(:transfer_collection, { transfer_id: id }, { persistent: true }) if processing?
  end

  def receipent_address
    cold_wallet_address
  end

  def amount_to_base_unit!
    currency = Currency.find_by_code(currency_id)
    x = amount.to_d * currency.base_factor
    unless (x % 1).zero?
      raise CoinAPI::Error, "Failed to convert value to base (smallest) unit because it exceeds the maximum precision: "  "#{amount.to_d} - #{x.to_d} must be equal to zero."
    end
    x.to_i
  end
end
