class Api::V1::AuthentificationController < ApplicationController
  before_action :get_user_by_login, only: [:login]

  AUTHENTIFICATION_MESSAGES = {
    login_in: "Successfully logged in",
    logged_out: "User successfully logged out",
    user_not_exist: "User does not exist",
    unauthorized_access: "Unauthorized access attempted",
    password_incorrect: "Password incorrect",
    missmatching: "Missmatched token",
    already_confirmed: "User has already confirmed their account",
    not_confirmed: "User has not confirmed their account",
  }

  def login
    if @user
      if @user.authenticate(user_login_parameters[:password])
        access_token = AuthentificationTokenService.create_token(@user, :access)
        refresh_token = AuthentificationTokenService.create_token(@user, :refresh)

        response = {
          message: AUTHENTIFICATION_MESSAGES[:login_in], 
          user: except_data(@user).merge(
            {
              access_token: access_token.to_s, 
              refresh_token: refresh_token.to_s
            }
          )
        }
        render json: response, status: :ok
      else
        message = {message: AUTHENTIFICATION_MESSAGES[:password_incorrect]}
        render json: message, status: :unprocessable_entity
      end  
    else 
      message = {message: AUTHENTIFICATION_MESSAGES[:user_not_exist]}
      render json: message, status: :unprocessable_entity
    end
  end
  
  def logout
    user_data = AuthentificationTokenService.decode_token(bearer_token)
    if user_data
      user = User.find_by(:login => user_data.first["login"])
      refresh_token = user_logout_parameters[:refresh_token]

      if (user && !user.tokens.empty? && user.tokens.find(refresh_token).any?)
        #remove current refresh token
        message = {message: AUTHENTIFICATION_MESSAGES[:logged_out]}
        render json: message, status: :ok
      else
        message = {message: AUTHENTIFICATION_MESSAGES[:missmatching]}
        render json: message, status: :unauthorized
      end
    else
      message = {message: AUTHENTIFICATION_MESSAGES[:unauthorized_access]}
      render json: message, status: :unauthorized
    end
  end

  def refresh

  end

  def confirm
    user_data = AuthentificationTokenService.decode_token(bearer_token)
    if user_data
      user = User.find_by(:login => user_data.first["login"])
      if user
        if user.confirmed.eql?(false) && user.set(confirmed: true)
          message = {message: AUTHENTIFICATION_MESSAGES[:missmatching]}
          render json: message, status: :ok
        else
          message = {message: AUTHENTIFICATION_MESSAGES[:not_confirmed]}
          render json: message, status: :unprocessable_entity
        end
      else
        message = {message: AUTHENTIFICATION_MESSAGES[:missmatching]}
        render json: message, status: :unauthorized
      end
    else
      message = {message: AUTHENTIFICATION_MESSAGES[:unauthorized_access]}
      render json: message, status: :unauthorized
    end
  end

  private
  def user_login_parameters
    params.permit(:login, :password, :remember_me)
  end

  def user_logout_parameters
    params.permit(:refresh_token)
  end
  
  def get_user_by_login
    @login = param_to_search(user_auth_parameters[:login])
    @user = User.find_by(:login => @login)
  end
end