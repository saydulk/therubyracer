class Token::SigninVerify < ::Token

  attr_accessor :email
  before_validation :set_member, on: :create

  private
  def set_member
    if member = Member.find_by_email(self.email)
      self.member = member
    end
  end

end