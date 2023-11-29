class ApplicationController < ActionController::Base
  before_action :authenticate_user!, except: [:top, :about]
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :user_state, only: [:create]

  def user_state
    user = User.find_by(email: params[:user][:email])
    return if !user
    if user.valid_password?(params[:user][:password]) && user.is_deleated == true
      redirect_to new_user_registration_path
    end
  end

  def new
    @user = User.new
  end

  def after_sign_in_path_for(resource)
    root_path
  end

  def after_sign_out_path_for(resource)
    root_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:last_name, :first_name, :last_name_kana, :first_name_kana, :nickname])
  end
end
