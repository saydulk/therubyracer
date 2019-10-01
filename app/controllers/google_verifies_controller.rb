class GoogleVerifiesController < ApplicationController
  before_action :set_member

  layout 'landing', only: :new

  def new
    @google_verify = GoogleVerify.new
  end

  def create
    otp = params[:google_verify][:otp_code_token].present? ? params[:google_verify][:otp_code_token] : params[:google_verify][:otp_code]
    if otp.size > 0 && @member.last_otp != otp
      if @member.authenticate_otp(otp, drift: 60)
        reset_session rescue nil
        session[:member_id] = @member.id
        save_session_key @member.id, cookies['_peatio_session']
        user_agent = UserAgent.parse(request.env["HTTP_USER_AGENT"])
        browser_type = user_agent.browser
        ip_address = request.env['REMOTE_ADDR']
        activity = Activity.create(ip_address: ip_address,member_id: @member.id,is_logged: true, browser_type: browser_type, session_id: cookies['_peatio_session'] )
        Activity.where(is_authorized: true, member_id: @member.id).update_all(is_authorized: false)
        cookies[:activity_id] = activity.try(:id)
        @member.update_columns(last_otp: otp)
        # MemberMailer.notify_signin(@member.id).deliver if @member.activated?
        redirect_on_successful_sign_in
      else
        clear_all_sessions @member.id
        reset_session
        redirect_to signin_path, alert: 'Bad Credentials Supplied.'
      end
    else
      clear_all_sessions @member.id
      reset_session
      redirect_to signin_path, alert: 'Your account needs to supply a token.'
    end
  end

  private

  def redirect_on_successful_sign_in
    "#{params[:provider].to_s.upcase}_OAUTH2_REDIRECT_URL".tap do |key|
       ENV[key] ? (redirect_to ENV[key]) : (redirect_back_or_settings_page)
    end
  end

  def set_member
    @member = Member.find(params[:id])
  end
end
