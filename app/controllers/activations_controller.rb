class ActivationsController < ApplicationController
  include Concerns::TokenManagement

  before_action :auth_member!,    only: :new
  before_action :verified?,       only: :new
  before_action :token_required!, only: :edit

  def new
    current_user.send_activation
    redirect_to settings_path
  end

  def edit
    if @token.confirm!
      redirect_to email_verify_path(flag: true)
    else
      redirect_to email_verify_path(flag: false)
    end
  end

  private

  def verified?
    if current_user.activated?
      redirect_to settings_path, notice: t('private.settings.index.verification.verified')
    end
  end

end
