class ShopperPasswordResetsController < ApplicationController
  layout "reset_password"
  def new
  end
  def create
    shopper = Shopper.find_by_email(params[:email])
    shopper.send_password_reset if shopper
    redirect_to root_url, :notice => "Email sent with password reset instructions."
  end

  def edit
    @shopper = Shopper.find_by_reset_password_token!(params[:id])
  end

  def update
    @shopper = Shopper.find_by_reset_password_token!(params[:id])
      I18n.locale = @shopper.language.to_sym
    if @shopper.reset_password_sent_at < 24.hours.ago
      redirect_to new_password_reset_path, :alert => I18n.t("emails.alert_message")
    elsif @shopper.update!(password: params[:shopper][:password], password_confirmation: params[:shopper][:password_confirmation])
      render 'shopper_password_resets/success', :notice =>  I18n.t("emails.success_reset_password")
    else
      render :edit
    end
  end
end
