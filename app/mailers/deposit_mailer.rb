class DepositMailer < BaseMailer

  def accepted(deposit_id)
    @deposit = Deposit.find deposit_id
    mail to: @deposit.member.email, subject: "[BitCorex] Deposit Success Alerts  -  #{Time.zone.now.strftime("%Y-%m-%d %I:%M:%S")}(UTC)"
  end

end
