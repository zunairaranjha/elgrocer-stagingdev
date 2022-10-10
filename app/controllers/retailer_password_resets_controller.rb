class RetailerPasswordResetsController < ApplicationController
  def new
  end
  def create
    retailer = Retailer.find_by_email(params[:email])
    retailer.send_password_reset if retailer
    redirect_to root_url, :notice => "Email sent with password reset instructions."
  end

  def edit
    @retailer = Retailer.find_by_reset_password_token!(params[:id])
  end

  def update
    @retailer = Retailer.find_by_reset_password_token!(params[:id])

    if @retailer.reset_password_sent_at < 24.hours.ago
      redirect_to new_password_reset_path, :alert => "Password reset has expired."
    elsif @retailer.update_attributes(password: params[:retailer][:password], password_confirmation: params[:retailer][:password_confirmation])
      render 'retailer_password_resets/success', :notice => "Password has been reset!"
    else
      render :edit
    end
  end
end
