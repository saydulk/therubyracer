class Token::MobileTokenCode < ::Token
  after_create :send_token
  before_validation :generate_token, on: :create

  attr_accessor :ip


  def confirm!
    super
    member.active!
  end

  private


  def send_token
    TokenMailer.send_token_on_mobile(member.email, Token::MobileTokenCode.decode_token(token), ip).deliver
  end

  def generate_token
    self.token = Token::MobileTokenCode.encode_token six_digits_random
    self.expires_at = 30.minutes.from_now
  end

  class << self
    def encode_token code
      Base64.encode64(code)
    end

    def decode_token encoded_token
      Base64.decode64(encoded_token)
    end
  end

  def six_digits_random
    begin
      rand_number = SecureRandom.random_number(1000000).to_s
      rand_number.length == 6 ? rand_number : raise
    rescue
      retry
    end
  end

end
