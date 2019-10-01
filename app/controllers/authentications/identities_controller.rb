module Authentications
  class IdentitiesController < ApplicationController
    before_filter :auth_anybody!, only: :new
    # before_action :auth_member!

    def new
      # @identity = Identity.new(email: current_user.email)
      @identity = request.env['omniauth.identity'] || Identity.new
    end

    def edit
      @identity = current_user.identity
    end

    def update
      @identity = current_user.identity

      unless @identity.authenticate(params[:identity][:old_password])
        redirect_to edit_identity_path, alert: t('.auth-error') and return
      end

      if @identity.authenticate(params[:identity][:password])
        redirect_to edit_identity_path, alert: t('.auth-same') and return
      end

      if @identity.update_attributes(identity_params)
        current_user.send_password_changed_notification
        clear_all_sessions current_user.id
        reset_session
        redirect_to signin_path, notice: t('.notice')
      else
        render :edit
      end
    end


    def create
      identity = Identity.new(identity_params.merge(email: current_user.email))
      if identity.save && current_user.create_auth_for_identity(identity)
        redirect_to settings_path, notice: t('.success')
      else
        redirect_to new_authentications_identity_path, alert: identity.errors.full_messages.join(',')
      end
    end

    private

    def identity_params
      params.required(:identity).permit(:password, :password_confirmation)
    end

  end
end
