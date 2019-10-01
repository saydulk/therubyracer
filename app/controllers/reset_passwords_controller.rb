class ResetPasswordsController < ApplicationController
  include Concerns::TokenManagement

  before_action :token_required, :only => [:edit, :update]
  before_action :auth_anybody!
  layout 'landing'

  def new
    @token = Token::ResetPassword.new
  end

  def create
    (redirect_to url_for(action: :new), alert: t('reset_passwords.create.blank_email')) and return  unless params[:reset_password][:email].present?

    @token = Token::ResetPassword.new(reset_password_params)

    if @token.save
      clear_all_sessions @token.member_id
      redirect_to signin_path, notice: t('reset_passwords.create.success')
    else
      redirect_to url_for(action: :new), alert: @token.errors.full_messages.join(', ')
    end
  end

  def edit
  end

  def update
    if @token.update_attributes(reset_password_update_params)
      @token.confirm!
      redirect_to signin_path, alert: t('reset_passwords.create.msg')
    else
      render :edit
    end
  end

  private
  def reset_password_params
    params.required(:reset_password).permit(:email)
  end

  def reset_password_update_params
    params.required(:reset_password).permit(:password, :password_confirmation)
  end
end
