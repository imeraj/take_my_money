class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def current_user
    return nil if session[:awaiting_twillio_user_id].present?
    super
  end
end
