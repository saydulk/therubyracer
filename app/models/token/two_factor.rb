class Token::TwoFactor < ::Token
  after_create :send_token

  attr_accessor :auth_type

  def confirm!
    super
    member.active!
  end

  private


  def send_token
    TokenMailer.two_factor(member.email, auth_type, token).deliver
  end
end
