require 'csv'
class Withdraw < ActiveRecord::Base
  # STATES = [:submitting, :submitted, :rejected, :accepted, :suspect, :processing,
  #           :done, :canceled, :almost_done, :failed]
  STATES = [:submitting, :submitted, :approved, :rejected, :accepted, :suspect, :processing,
            :done, :canceled, :failed, :confirming]
  # COMPLETED_STATES = [:done, :rejected, :canceled, :almost_done, :failed]
  COMPLETED_STATES = [:done, :rejected, :canceled, :failed]

  extend Enumerize

  include AASM
  include AASM::Locking
  include Currencible

  has_paper_trail on: [:update, :destroy]

  enumerize :aasm_state, in: STATES, scope: true

  belongs_to :member
  belongs_to :account
  has_many :account_versions, as: :modifiable
  has_one :airdrop_history

  delegate :balance, to: :account, prefix: true
  delegate :key_text, to: :channel, prefix: true
  delegate :id, to: :channel, prefix: true
  delegate :name, to: :member, prefix: true
  delegate :coin?, :fiat?, to: :currency_obj

  before_validation :fix_precision
  before_validation :calc_fee
  before_validation :set_account
  after_create :generate_sn

  after_update :sync_update
  after_create :sync_create
  after_destroy :sync_destroy

  validates_with WithdrawBlacklistValidator

  validates :fund_uid, :amount, :fee, :account, :currency, :member, presence: true

  validates :fee, numericality: {greater_than_or_equal_to: 0}
  validates :amount, numericality: {greater_than: 0}

  validates :sum, presence: true, numericality: {greater_than: 0}, on: :create
  validates :txid, uniqueness: true, allow_nil: true, on: :update

  validate :ensure_account_balance, on: :create

  scope :completed, -> {where aasm_state: COMPLETED_STATES}
  scope :not_completed, -> {where.not aasm_state: COMPLETED_STATES}
  scope :recent, -> { order('id DESC')}

  def self.channel
    WithdrawChannel.find_by_key(name.demodulize.underscore)
  end

  def self.write_date_csv
    attributes = %w{Status Coin Amount Date Address Txid }
    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |data|
        row_data = []
        row_data << data.aasm_state.capitalize
        row_data << data.currency.upcase
        row_data << data.amount
        row_data << data.created_at
        row_data << data.fund_uid
        row_data << data.txid
        csv << row_data
      end
    end
  end

  def self.export(data)
    attributes = %w(ID  Created\ at Currency Account Bank Amount State/Actions )
    CSV.generate(headers: true) do |csv|
      csv << attributes
      if data.present?
        data.each do |val|
          row_data = []
          row_data << val[:id]
          row_data << val[:created_at]
          row_data << val[:currency].upcase
          row_data << (val.member_name || "admin/members/#{val.member.id}")
          row_data << val[:amount]
          row_data << "#{val[:fund_extra]} # #{val[:fund_uid]}"
          row_data << val[:aasm_state].capitalize
          csv << row_data
        end
      end
    end
  end

  def channel
    self.class.channel
  end

  def channel_name
    channel.key
  end

  alias_attribute :withdraw_id, :sn
  alias_attribute :full_name, :member_name

  def generate_sn
    id_part = sprintf '%04d', id
    date_part = created_at.localtime.strftime('%y%m%d%H%M')
    self.sn = "#{date_part}#{id_part}"
    update_column(:sn, sn)
  end

  aasm :whiny_transitions => false do
    state :submitting, initial: true
    state :submitted
    state :approved
    state :canceled
    state :accepted
    state :suspect
    state :rejected
    state :processing
    state :done
    state :failed
    state :confirming

    event :submit, after_commit: :send_email do
      transitions from: :submitting, to: :submitted
      # transitions from: :submitting, to: :processing
      after do
        lock_funds
      end
    end

    event :cancel, after_commit: :send_email do
      transitions from: [:submitting, :submitted, :accepted, :approved], to: :canceled
      after do
        after_cancel
      end
    end

    event :mark_suspect, after_commit: :send_email do
      transitions from: :submitted, to: :suspect
    end

    event :approve do
      transitions from: :submitted, to: :approved
    end

    event :accept do
      transitions from: :approved, to: :accepted
    end

    event :reject, after_commit: :send_email do
      transitions from: [:submitted, :submitting, :approved], to: :rejected
      after :unlock_funds
    end

    event :process, after_commit: %i[ send_coins! send_email ] do
      transitions from: :accepted, to: :processing
    end

    event :dispatch do
      # TODO: add validations that txid and block_number are not blank.
      transitions from: :processing, to: :confirming
    end

    # event :call_rpc do
    #   transitions from: :processing, to: :almost_done
    # end

    event :succeed, after_commit: :send_email do
      transitions from: :confirming, to: :done

      before [:set_txid, :unlock_and_sub_funds]
    end

    event :fail, after_commit: :send_email do
      transitions from: %i[processing confirming approved], to: :failed
      after :unlock_funds
    end
  end

  def cancelable?
    submitting? or submitted? or accepted?
  end

  def quick?
    sum.to_d <= currency_obj.quick_withdraw_max.to_d
  end

  def audit!
    with_lock do
      if account.examine
        accept
        process if quick?
      else
        mark_suspect
      end
      save!
    end

    # FIXME: Unfortunately AASM doesn't fire after_commit
    # callback (don't be confused with ActiveRecord's after_commit).
    # This probably was broken after upgrade of Rails & gems.
    # The fix is to manually invoke #send_coins! and #send_email.
    # NOTE: These calls should be out of transaction so fast workers
    # would not start processing data before it was committed to DB.
    send_coins! if processing?
    send_email
  end

  private

  def after_cancel
    unlock_funds unless aasm.from_state == :submitting
  end

  def lock_funds
    account.lock!
    account.lock_funds sum, reason: Account::WITHDRAW_LOCK, ref: self
  end

  def unlock_funds
    account.lock!
    account.unlock_funds sum, reason: Account::WITHDRAW_UNLOCK, ref: self
  end

  def unlock_and_sub_funds
    account.lock!
    account.unlock_and_sub_funds sum, locked: sum, fee: fee, reason: Account::WITHDRAW, ref: self
  end

  def set_txid
    self.txid = @sn unless coin?
  end

  def send_email
    case aasm_state
      when 'submitted'
        WithdrawMailer.submitted(self.id).deliver
      when 'processing'
        WithdrawMailer.processing(self.id).deliver
      when 'done'
        WithdrawMailer.done(self.id).deliver
      else
        # withdraw_rejected_mail
        # WithdrawMailer.withdraw_state(self.id).deliver
    end
  end

  def send_coins!
    AMQPQueue.enqueue(:withdraw_coin, id: id) if coin?
  end

  def ensure_account_balance
    if sum.nil? or sum > account.balance
      errors.add :base, -> {I18n.t('activerecord.errors.models.withdraw.account_balance_is_poor')}
    end
  end

  def fix_precision
    if sum && currency_obj.precision
      self.sum = sum.round(currency_obj.precision, BigDecimal::ROUND_DOWN)
    end
  end

  def calc_fee
    # if respond_to?(:set_fee)
    #   set_fee
    # end
    self.sum ||= 0.0
    # self.fee ||= 0.0
    self.fee ||= WithdrawChannel.find_by_currency(currency).fee
    self.amount = sum - fee
  end

  def set_account
    self.account = member.get_account(currency)
  end

  def self.resource_name
    name.demodulize.underscore.pluralize
  end

  def sync_update
    ::Pusher["private-#{member.sn}"].trigger_async('withdraws', {type: 'update', id: self.id, attributes: self.changes_attributes_as_json})
  end

  def sync_create
    ::Pusher["private-#{member.sn}"].trigger_async('withdraws', {type: 'create', attributes: self.as_json})
  end

  def sync_destroy
    ::Pusher["private-#{member.sn}"].trigger_async('withdraws', {type: 'destroy', id: self.id})
  end
end
