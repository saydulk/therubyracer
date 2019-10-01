class MembersController < ApplicationController
  before_filter :auth_member!
  before_filter :auth_no_initial!, :except => :balance_summary


  def edit
    @member = current_user
  end

  def update
    @member = current_user

    if @member.update_attributes(member_params)
      redirect_to forum_path
    else
      render :edit
    end
  end

  def balance_summary
    if params[:search].present?

      @member_accounts = current_user.accounts.with_currency(params[:search].downcase.strip)
    else
      order = params[:order].nil? ? 'asc' : params[:order]
      @member_accounts = current_user.accounts.order(currency: order)
    end

    @estimate_amount , @in_use = current_user.set_estimated_price @member_accounts

    if request.xhr?
      respond_to do |format|
        format.js
      end
    end
  end

  private

  def member_params
    params.required(:member).permit(:display_name)
  end
end
