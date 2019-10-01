module Withdrawable
  extend ActiveSupport::Concern

  included do
    include AASM
    include AASM::Locking
    include Currencible
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
        transitions from: :processing, to: :confirming
      end

      event :succeed do
        transitions from: :confirming, to: :done
      end

      event :fail do
        transitions from: %i[processing confirming], to: :failed
      end
    end

    def audit_transfer!
      with_lock do
        accept
        process
        save!
      end
    end
  end

end