class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale

  def set_locale
    I18n.locale = request.headers['Locale'] || params[:locale] || I18n.default_locale
    # Time.zone = current_admin_user.current_time_zone if current_admin_user
  end
end
