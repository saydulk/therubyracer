class IdDocument < ActiveRecord::Base
  extend Enumerize
  include AASM
  include AASM::Locking

  has_one :id_document_file, class_name: 'Asset::IdDocumentFile', as: :attachable
  accepts_nested_attributes_for :id_document_file

  has_one :id_bill_file, class_name: 'Asset::IdBillFile', as: :attachable
  accepts_nested_attributes_for :id_bill_file

  belongs_to :member

  validates_presence_of :name, :id_document_type, :id_document_number, :id_bill_type, allow_nil: true
  validates_uniqueness_of :member
  validates :contact_no, presence: true, on: :update

  enumerize :id_document_type, in: {id_card: 0, passport: 1, driver_license: 2}
  enumerize :id_bill_type,     in: {'bank statement': 0, 'tax bill': 1}

  alias_attribute :full_name, :name

  validates_plausible_phone :contact_no, with: /\A\+\d+/, enforce_record_country: false, allow_nil: true

  validates_length_of :id_document_number, minimum: 6, allow_nil: true, on: :update

  validates :zipcode, zipcode: {country_code_attribute: :country_code }, allow_nil: true, zipcode: false, on: :update

  validates_length_of :name, :middle_name, :last_name, :maximum => 30, allow_nil: true, on: :update

  validates_length_of :city, :maximum => 30,  allow_nil: true, on: :update
  validates_length_of :address, :maximum => 300,  allow_nil: true, on: :update

  before_validation :normalize_contact_number

  scope :is_verified, -> (status) { where(aasm_state: status) }

  HUMANIZED_ATTRIBUTES = {
      :id_bill_type => "Proof Of Residence"
  }

  enum gender: {
      '0'=> 'Male',
      '1' => 'Female',
      '2' => 'Other'
  }


  aasm do
    state :unverified, initial: true
    state :verifying
    state :verified

    event :submit do
      transitions from: :unverified, to: :verifying
    end

    event :approve do
      transitions from: [:unverified, :verifying],  to: :verified
      #after :assign_referral_bonus
    end

    event :reject do
      transitions from: [:verifying, :verified],  to: :unverified
    end
  end

  def self.export(data)
    attributes = %w(Name Email Id\ Document\ Type Id\ Bill\ Type  Request\ At Verified )
    csv_data = CSV.generate do |csv|
      csv <<  attributes
      if data.present?
        data.each do |val|
          row_data = []
          row_data << val[:name]
          row_data << val.member[:email]
          # row_data << val[:id_document_type]
          row_data << val[:id_bill_type]
          row_data << val[:updated_at]
          row_data << (val.verified? ? 'Yes' : 'No')
          csv << row_data
        end
      end
    end
    return csv_data
  end

  def self.human_attribute_name(attr, options = {})
    attr == :id_bill_type ? "Proof Of Residence" : HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  private

  def normalize_contact_number
    self.contact_no = PhonyRails.normalize_number(contact_no, country_code: country_code) if contact_no.present?
  end

  def assign_referral_bonus
    return unless sponsor = member.sponsor

    if sponsor && plan = Referral.active
      currency = Currency.find_by_code(plan.currency)
      return unless currency.is_erc20?
      account = member.accounts.find_by(currency: plan.currency)
      return if account.payment_address.address.nil?
      balance =  if currency.try(:api_client).present?
                   "CoinAPI::#{currency.api_client.camelize}"
                 else
                   "CoinAPI::#{code.upcase}"
                 end.constantize.new(currency).load_balance!
      account.update_columns(balance: plan.amount) if sponsor.id_document.verified? && plan.amount.to_i < balance
    end
  end
end
