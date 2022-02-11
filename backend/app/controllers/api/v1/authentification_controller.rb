class Api::V1::AuthentificationController < ApplicationController
  before_action :get_user_by_login, only: [:login]

  include ActionController::Cookies

  AUTHENTIFICATION_MESSAGES = {
    login_in: "Successfully logged in",
    logged_out: "User successfully logged out",
    user_not_exist: "User does not exist",
    unauthorized_access: "Unauthorized access attempted",
    password_incorrect: "Password incorrect",
    missmatching: "Missmatched token",
    already_confirmed: "User has already confirmed their account",
    not_confirmed: "User has not confirmed their account",
    not_login: "Not logged in",
  }

  def login
    if @user
      if @user.authenticate(user_login_parameters[:password])
        token_data = @user.as_json.merge({ip: user_login_parameters[:ip_address]})
        refresh_token = AuthentificationTokenService.create_token(token_data, :refresh)
        access_token = AuthentificationTokenService.create_token(token_data, :access)

        if @user.tokens.present?
          @user.set(tokens: @user.tokens << refresh_token) 
        else
          @user.set(tokens: [refresh_token])
        end

        cookies["refresh_token"] = { value: refresh_token, httponly: true }
        response = {
          message: AUTHENTIFICATION_MESSAGES[:login_in], 
          user: except_data(@user).merge(
            {
              access_token: access_token.to_s, 
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
      if (user && !user.tokens.empty? && user.tokens.find(cookies["refresh_token"]).any?)
        @user.set(tokens: @user.tokens.as_json.filter{ |t| t.eql? cookies["refresh_token"] })
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
    params.permit(:login, :password, :remember_me, :ip_address)
  end

  def user_logout_parameters
    params.permit(:refresh_token)
  end
  
  def get_user_by_login
    @login = param_to_search(user_login_parameters[:login])
    @user = User.find_by(:login => @login)
  end
end