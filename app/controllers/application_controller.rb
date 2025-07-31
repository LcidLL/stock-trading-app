class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  def authenticate_user!
    unless trader_signed_in? || admin_user_signed_in?
      redirect_to root_path, alert: 'Please log in to continue.'
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    case resource_or_scope
    when :trader
      root_path
    when :admin_user
      new_admin_user_session_path
    when :admin
      new_admin_session_path
    else
      root_path
    end
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(AdminUser)
      admin_dashboard_path
    elsif resource.is_a?(Trader)
      trader_dashboard_path(resource)
    elsif resource.is_a?(Admin)
      root_path
    else
      super
    end
  end
end