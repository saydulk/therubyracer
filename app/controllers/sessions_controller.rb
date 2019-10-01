class SessionsController < ApplicationController
  # invisible_captcha only: :create, on_spam: :your_spam_callback_method
  skip_before_action :verify_authenticity_token, only: [:create]

  before_action :auth_member!, only: :destroy
  before_action :auth_anybody!, only: :failure
  before_action :location_user,only: [:new ,:create]
  # before_action :terms_must_be_selected_on_register, only: :create

  layout 'landing'

  def new
    if @current_user
      redirect_to settings_path
    else

      # Activity.where(
      #     ip_address: request.remote_ip,
      #     is_logged: true,
      #     browser_type: UserAgent.parse(request.env["HTTP_USER_AGENT"]).browser
      # ).update_all(is_logged: false)

      @identity = Identity.new

    end

  end

  def create
    cookies[:is_logged] = false
    @member = Member.from_auth(auth_hash)
    if @member
      existing_activity =  user_activity
      if params[:register].present? || params[:provider] == "google_oauth2" || params[:provider] == "facebook"
        member_session
      else
        if  I18n.locale == :zh or location_user == 'CN'
          if verify_rucaptcha?(@member)
            # check_existing_session and return if existing_activity
            pending_member_account
            enqueue_address_generation
            member_session
          else
            redirect_to signin_path, alert: t('sessions.create.recaptcha_failed')
          end
        else
          if verify_recaptcha(model: @member)
            # check_existing_session and return if existing_activity
            pending_member_account
            enqueue_address_generation
            member_session
          else
            redirect_to signin_path, alert: t('sessions.create.recaptcha_failed')
          end

        end
      end
    else
      redirect_on_unsuccessful_sign_in
    end
  end

  def clear_existing_session
    @ip_address = params[:ip_address]
    @is_devise = false

    if params.has_key? 'devise_type'
      @user_agent = params[:devise_type]
      @user_agent1 = @user_agent2 = @location = ''
      token = BlacklistToken.find_by_id(params[:id])
      token.update_column(:in_use, false) if token
      @is_devise = true
    else
      @user_agent = params[:browser]
      @user_agent1 = params[:os]
      @user_agent2 = params[:version]
      @location = params[:location]
      @ip_address = params[:ip_address]
      token = Token::SigninVerify.find_by_token(params[:id])
      user_activities = Activity.where(member_id: token&.member_id, is_logged: true)
      if token.present? && !token.is_used? && user_activities
        token.update_attributes(is_used: true)
        Activity.create(member_id: params[:m_id],is_logged:false, is_authorized:true,ip_address:@ip_address,browser_type: @user_agent)
      end
    end
  end

  def failure
    redirect_to signin_path, alert: t('sessions.create.error')
  end

  def destroy
    current_id = current_user.id
    clear_all_sessions current_id
    reset_session
    activity = Activity.find_by(member_id: current_id, is_logged: true)
    activity.update_column(:is_logged, false) if activity
    redirect_to root_path
  end

  private

  def auth_hash
    @auth_hash ||= request.env['omniauth.auth']
  end

  def redirect_on_successful_sign_in
    "#{params[:provider].to_s.upcase}_OAUTH2_REDIRECT_URL".tap do |key|
      if ENV[key]
        redirect_to ENV[key]
      else
        redirect_back_or_settings_page
      end
    end
  end

  def redirect_on_unsuccessful_sign_in
    redirect_to signin_path, alert: t('sessions.create.error')
  end

  # def terms_must_be_selected_on_register
  #   if params[:register].present?
  #     (redirect_to :back , alert: t('sessions.create.no_terms')) and return if params[:identity][:conditions].eql?('0')
  #   end
  # end

  def user_activity
    user_agent = UserAgent.parse(request.env["HTTP_USER_AGENT"])
    browser_type = user_agent.browser
    ip_address = request.env['REMOTE_ADDR']
    is_logged = Activity.where(member_id: @member.id, is_logged: true)
    is_authorized = Activity.find_by(member_id:@member.id,ip_address:ip_address,is_authorized:true,browser_type:browser_type)
    if  is_authorized
       is_authorized.update_attributes(is_authorized: false)
       is_logged.update_all(is_logged: false, is_authorized: false)
       is_logged = nil
       return false
    else
      return is_logged.present?
    end

  end

  def member_session
    if @member.disabled?
      redirect_to signin_path, alert: t('sessions.create.disabled')
    elsif @member.disable? && @member.sms_disable?
      reset_session rescue nil
      session[:member_id] = @member.id
      save_session_key @member.id, cookies['_peatio_session']
      user_agent = UserAgent.parse(request.env["HTTP_USER_AGENT"])
      ip_address = request.env['REMOTE_ADDR']
      browser_type = user_agent.browser

      Activity.create(ip_address: request.remote_ip, member_id: @member.id, browser_type: browser_type, session_id: cookies['_peatio_session'])

      ## Remove above line for multiple loggedin
      # activity = Activity.create(ip_address: ip_address, member_id: @member.id, is_logged: true , browser_type: browser_type, session_id: cookies['_peatio_session'], is_authorized: false)
      # Activity.where(is_authorized: true, member_id: @member.id).update_all(is_authorized: false)
      # cookies[:activity_id] = activity.try(:id)



      #MemberMailer.notify_signin(@member.id).deliver if @member.activated?
      if @member.activated?
        redirect_on_successful_sign_in
      else
        session[:member_id] = @member.id if session[:member_id]
        redirect_to '/funds?#/deposits/btc'
      end
    elsif @member.enable? || @member.sms_enable?
      redirect_to google_verifies_path(@member)
    end
  end

  def pending_member_account
    member_accounts = @member.accounts.map(&:currency)
    currency = Currency.all.map(&:code)
    pending_currencies = (member_accounts - currency) | (currency - member_accounts)
    pending_currencies.compact.each do |pending_currency|
      currency_code = pending_currency.strip
      if currency_code.present? && currency_code != nil
        currency_priority = Currency.find_by_code(currency_code).priority
        @member.accounts.create(currency: currency_code, balance: 0.0, locked: 0.0, priority: currency_priority)
      end
    end
  end

  def check_existing_session
      @token = Token::SigninVerify.new(email: @member.email)
      if @token.save
        user_agent = UserAgent.parse(request.env["HTTP_USER_AGENT"])
        ip_address = request.env['REMOTE_ADDR']
        city = request.location.city
        country = request.location.country_code
        location = "#{city} #{country}"
        cookies[:is_logged] = true
        TokenMailer.signin_verify(@member.email, ip_address , user_agent, @token.token,location).deliver
        redirect_to signin_path
      end
  end

  def location_user
    @country_code = request.location.country_code
  end


  def enqueue_address_generation
   @member.accounts.each do |account|
     account.payment_address.gen_address if account.payment_address.address.blank?
   end
  end

end