# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]
  skip_before_action :verify_authenticity_token, only: [:create, :verify]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    @user = User.find_by(email: params[:user][:email])
    if @user&.valid_password?(params[:user][:password])
      session[:awaiting_twillio_user_id] = @user.id
      Twillio.new(@user).request_email
      render :two_factor
    else
      session[:awaiting_twillio_user_id] = nil
      super
    end
  end

  def verify
    @user = User.find(session[:awaiting_twillio_user_id])
    if Twillio.new(@user).verify(params[:token])
      sign_in(User, @user)
      session[:awaiting_twillio_user_id] = nil
      respond_with @user, location: after_sign_in_path_for(resource)
    else
      redirect_to users_sessions_two_factor_path
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
