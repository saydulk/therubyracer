class MemberMailer < BaseMailer

  def notify_signin(member_id)
    set_mail(member_id)
  end

  def reset_password_done(member_id)
    set_mail(member_id)
    mail to: @member.email, subject: "[BitCorex] Password changed -  #{Time.zone.now.strftime("%Y-%m-%d %I:%M:%S")}(UTC)"
  end

  def disable_google_auth(member_id, auth,ip)
    @auth = auth
    @member = Member.find member_id
    mail to: @member.email, subject: "[BitCorex] Google Authentication Disable Success From #{ip} -  #{Time.zone.now.strftime("%Y-%m-%d %I:%M:%S")}(UTC)"
  end

  private

  def set_mail(member_id)
     @member = Member.find member_id
    mail to: @member.email
  end
end
