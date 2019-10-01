class TwoFactorsController < ApplicationController
  include Concerns::TokenManagement
  # layout false


  def new
    @token = Token::TwoFactor.new
  end

  def create
    @token = Token::TwoFactor.new(member_id: params[:member_id], auth_type: params[:auth_type])
    if @token.save
      clear_all_sessions @token.member_id
      redirect_to signin_path, notice: t('two_factors.create.success')
    else
      redirect_to url_for(action: :new), alert: @token.errors.full_messages.join(', ')
    end
  end

  def show
    token = Token::TwoFactor.find_by_token(params[:id])
    if !(token.expired?) && %w(google mobile).include?(params[:type])
      member = token.member
      if params[:type].eql?('google')
        member.update(otp_module: 0)
      else params[:type].eql?('mobile')
        member.update(sms_auth: 0)
      end
      redirect_to signin_path, notice: t('two_factors.show.reset', type: (params[:type].eql?('mobile') ? 'SMS' : params[:type].to_s.capitalize))
    else
      redirect_to signin_path, alert: t('two_factors.show.token_expired')
    end
  end

  private

  def two_factor_params
    params.permit(:auth_type, :member_id)
  end
end
