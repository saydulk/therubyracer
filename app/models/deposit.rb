require 'csv'
class Deposit < ActiveRecord::Base
  STATES = [:submitting, :cancelled, :submitted, :rejected, :accepted,:collected, :checked, :warning]

  extend Enumerize

  include AASM
  include AASM::Locking
  include Currencible

  has_paper_trail on: [:update, :destroy]

  enumerize :aasm_state, in: STATES, scope: true

  alias_attribute :sn, :id

  delegate :name, to: :member, prefix: true, allow_nil: true
  delegate :id, to: :channel, prefix: true
  delegate :coin?, :fiat?, to: :currency_obj

  belongs_to :member
  belongs_to :account
  has_one :fiat_attachment

  validates_presence_of \
    :amount, :account, \
    :member, :currency
  validates_numericality_of :amount, greater_than: 0

  scope :recent, -> { order('id DESC')}

  after_update :sync_update
  after_create :sync_create
  after_destroy :sync_destroy

  aasm :whiny_transitions => false do
    #state :submitting, initial: true, before_enter: :set_fee
    state :submitted, initial: true, before_enter: :set_fee
    state :cancelled
    state :rejected
   # state :accepted, after_commit: [:do, :send_mail]
    state :accepted, after_commit: [:send_mail]
    state :collected
    state :checked
    state :warning

    # event :submit do
    #   transitions from: :submitting, to: :submitted
    # end

    event :cancel do
      transitions from: :submitted, to: :cancelled
    end

    event :reject do
      transitions from: :submitted, to: :rejected
    end

    event :accept do
      transitions from: :submitted, to: :accepted
      after :do
    end

    event :dispatch do
      transitions from: :accepted, to: :collected
    end

    event :check do
      transitions from: :accepted, to: :checked
    end

    event :warn do
      transitions from: :accepted, to: :warning
    end
  end

  def txid_desc
    txid
  end

  class << self
    def channel
      DepositChannel.find_by_key(name.demodulize.underscore)
    end

    def resource_name
      name.demodulize.underscore.pluralize
    end

    def params_name
      name.underscore.gsub('/', '_')
    end

    def new_path
      "new_#{params_name}_path"
    end

    def write_date_csv
      attributes = %w{Status Coin Amount Date Address Txid }
      CSV.generate(headers: true) do |csv|
        csv << attributes

        all.each do |data|
          row_data = []
          row_data << data.aasm_state.capitalize
          row_data << data.currency.upcase
          row_data << data.amount
          row_data << data.created_at
          row_data << data.address
          row_data << data.txid
          csv << row_data
        end
      end
    end

    def export(data)
      attributes = %w(txid  Created\ at Currency Member Amount Confirmations State/Actions )
      CSV.generate(headers: true) do |csv|
        csv << attributes
        if data.present?
          data.each do |val|

            row_data = []
            row_data << val[:txid].truncate(36)
            row_data << val[:created_at]
            row_data << val[:currency]
            row_data << (val.member_name || "admin/members/#{val.member.id}")
            # row_data << ("#{val[:fund_extra]} # #{val[:fund_uid]}")
            row_data << val[:amount]
            row_data << val[:confirmations]
            row_data << val[:aasm_state].capitalize
            csv << row_data
          end
        end
      end
    end

  end

  def channel
    self.class.channel
  end

  def update_confirmations(data)
    update_column(:confirmations, data)
  end

  def txid_text
    txid && txid.truncate(40)
  end


  def collect!
    if Currency.find_by_code(currency)&.api_client&.casecmp('ERC20') == 0
      AMQPQueue.enqueue(:deposit_collection_fees, id: id)
    else
      AMQPQueue.enqueue(:deposit_collection, id: id)
    end
  end


  private
  def do
    account.lock!.plus_funds amount, reason: Account::DEPOSIT, ref: self
  end

  def send_mail
    DepositMailer.accepted(self.id).deliver if self.accepted?
  end

  def set_fee
    amount, fee = calc_fee
    self.amount = amount
    self.fee = fee
  end

  def calc_fee
    [amount, 0]
  end

  def sync_update
    ::Pusher["private-#{member.sn}"].trigger_async('deposits', { type: 'update', id: self.id, attributes: self.changes_attributes_as_json })
  end

  def sync_create
    ::Pusher["private-#{member.sn}"].trigger_async('deposits', { type: 'create', attributes: self.as_json })
  end

  def sync_destroy
    ::Pusher["private-#{member.sn}"].trigger_async('deposits', { type: 'destroy', id: self.id })
  end

end
