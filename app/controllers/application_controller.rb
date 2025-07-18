class ApplicationController < ActionController::Base
  before_action :authenticate_admin_user!
  allow_browser versions: :modern
end
