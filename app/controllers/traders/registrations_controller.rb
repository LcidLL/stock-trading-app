class Traders::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  def create
    super do |resource|
      if resource.persisted?
        resource.update(status: :pending)
        sign_out(resource)
      end
    end
  end

  def after_sign_up_path_for(resource)
    root_path
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def after_inactive_sign_up_path_for(resource)
    root_path
  end
end