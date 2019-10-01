class TokenMailer < BaseMailer

  def reset_password(email, token)
    @token_url = edit_reset_password_url(token)
    @email = email
    mail to: email
  end

  def support_email(email, support)
    @support = support
    mail to: email, subject:"[BitCorex] Email from user - #{Time.zone.now.strftime("%Y-%m-%d %I:%M:%S")}(UTC)"
  end

  def activation(email, token)
    @token_url = edit_activation_url token
    mail to: email, subject:"[BitCorex] Confirm Your Registration - #{Time.zone.now.strftime("%Y-%m-%d %I:%M:%S")}(UTC)"
  end

  def two_factor(email, auth_type, token)
    @token_url = two_factor_url(token) + "?type=#{auth_type}"
    @type = auth_type
    mail to: email
  end

  def send_token_on_mobile(email, token_code, ip)
    @token_code = token_code
    @email = email
    mail to: email, subject: "[BitCorex] Password Reset from #{ip} at - #{Time.zone.now.strftime("%Y-%m-%d %I:%M:%S")}(UTC)"
  end

  def signin_verify(email, ip_address, user_agent, token, location, is_devise = false)
     if @is_devise = is_devise
       @token_url = clear_session_url id: token, ip_address: ip_address, devise_type: user_agent
     else
       @token_url = clear_session_url id: token, ip_address: ip_address , browser: user_agent.browser, os: user_agent.os, version: user_agent.version, location: location , m_id: Member.find_by_email(email)&.id
     end

     @email = email
     @ip_address = ip_address
     @user_agent = user_agent
     @location =location
     mail to: email, subject:  "[BitCorex] Authorize New Device #{@user_agent.browser},#{@user_agent.os},#{@user_agent.version} - #{@ip_address} at - #{Time.zone.now.strftime("%Y-%m-%d %I:%M:%S")}(UTC)"
  end

end
