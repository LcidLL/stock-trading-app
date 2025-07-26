
class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  
  include Devise::Controllers::Helpers
  
  def authenticate_user!
    unless admin_user_signed_in? || trader_signed_in?
      redirect_to root_path, alert: 'Please log in to continue.'
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end