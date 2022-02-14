class Api::V1::AuthentificationController < ApplicationController
  before_action :get_user_by_login, only: [:login]
  before_action :decode_bearer_token!, only: [:logout]
  before_action :token_expired?, only: [:confirm]

  include ActionController::Cookies

  def login
    if @user
      if @user.authenticate(user_login_parameters[:password])
        response = {
          message: ApiError::MESSAGES[:auth][:login_in], 
          user: except_data!(@user).merge(
            # Добаваить метрику об устройстве...
            issue_tokens(@user)
          )
        }
        render json: response, status: :ok
      else
        message = {message: ApiError::MESSAGES[:auth][:password_incorrect]}
        render json: message, status: :unprocessable_entity
      end  
    else 
      message = {message: ApiError::MESSAGES[:auth][:user_not_exist]}
      render json: message, status: :not_found
    end
  end
  
  def logout
    if @user_data
      user = User.find_by(login: @user_data.first["login"])
      if (user && !user.tokens.empty? && user.tokens.filter{|t| t == cookies["refresh_token"]}.length > 0)
        user.set(tokens: user.tokens.as_json.filter{ |t| t != cookies["refresh_token"] })
        message = {message: ApiError::MESSAGES[:auth][:logged_out]}
        render json: message, status: :ok
      else
        message = {message: ApiError::MESSAGES[:auth][:missmatching]}
        render json: message, status: :not_acceptable
      end
    else
      message = {message: ApiError::MESSAGES[:auth][:unauthorized_access]}
      render json: message, status: :unauthorized
    end
  end

  def confirm
      user = User.find_by(:login => user_confirmation_params[:code])
      if user
        if user.confirmed.eql?(false) || !user.confirmed.present?
          if user.set(confirmed: true) 
            message = {message: ApiError::MESSAGES[:auth][:confirmed]}
            render json: message, status: :ok
          else
            message = {message: ApiError::MESSAGES[:auth][:not_confirmed]}
            render json: message, status: :not_modified
          end
        else
          message = {message: ApiError::MESSAGES[:auth][:already_confirmed]}
          render json: message, status: :ok  
        end
      else
        message = {message: ApiError::MESSAGES[:auth][:unauthorized_access]}
        render json: message, status: :unprocessable_entity
      end
  end

  def refresh
    if @user_data
      user = User.find_by(login: @user_data.first["login"])
      
      if (user && !user.tokens.empty? && user.tokens.find(cookies["refresh_token"]).any?)
        user.set(tokens: user.tokens.as_json.filter{ |t| t != cookies["refresh_token"] })
        response = {
          message: ApiError::MESSAGES[:auth][:login_in], 
          user: except_data!(@user).merge(
            # Добаваить метрику об устройстве...
            issue_tokens(@user)
          )
        }
        render json: response, status: :ok
      else
        message = {message: ApiError::MESSAGES[:auth][:missmatching]}
        render json: message, status: :not_acceptable
      end
    else
      message = {message: ApiError::MESSAGES[:auth][:unauthorized_access]}
      render json: message, status: :unauthorized
    end
  end

  private
  def user_confirmation_params
    params.permit(:code)
  end

  def user_login_parameters
    params.permit(:login, :password, :remember_me)
  end
  
  def get_user_by_login
    @login = param_to_search(user_login_parameters[:login])
    @user = User.find_by(:login => @login)
  end
end