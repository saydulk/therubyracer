class SupportsController < ApplicationController
  layout 'landing'

  def new
    @supports = Support.new
  end

  def create
    @supports = Support.new(detail_params)
    if verify_recaptcha(model:  @supports)
      @supports.save
      TokenMailer.support_email(ENV['ADMIN'], @supports).deliver
      redirect_to :back, notice: t('supports.create.success')
    else
      render :new
    end
  end

  private

  def detail_params
    params.require(:support).permit(:name, :body, :email, :url, :contact_no)
  end
end


