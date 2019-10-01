class Identity < OmniAuth::Identity::Models::ActiveRecord
  auth_key :email
  attr_accessor :old_password, :description, :conditions

  MAX_LOGIN_ATTEMPTS = 5
  HUMANIZED_ATTRIBUTES = {
      :password_confirmation => "",
       email: '',
       password: '',
       conditions: ''
  }
  validates :email, presence: true, uniqueness: true, email: true

  validates :password, presence: true

  validates :password, length: { minimum: 8, maximum: 64}

  validates :password, format: { with: Rails.application.config.PASSWORD_FORMAT , multiline: true}

  validates :password_confirmation, presence: true

  validates :conditions, :acceptance => { :accept => '1', message: I18n.t('activerecord.error.messages.condition') }, on: :create

  before_validation :sanitize

  def increment_retry_count
    self.retry_count = (retry_count || 0) + 1
  end

  def too_many_failed_login_attempts
    retry_count.present? && retry_count >= MAX_LOGIN_ATTEMPTS
  end

  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  private

  def sanitize
    self.email.try(:downcase!)
  end

end
