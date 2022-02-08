class Api::V1::AuthentificationController < ApplicationController
  before_action :get_user_by_login, only: [:login]

  def login
    if @user
      if @user.authenticate(user_auth_parameters[:password])
        jwt = AuthentificationTokenService.create_token(@user)
        if @user.set(token: jwt) && !@user.token.present?
          out = {message: "Successfully logged in", user: except_data(@user)}
          render json: out, status: :ok
        else
          message = {message: "User has been already authenticated or token can not be applied"}
          render json: message, status: :unprocessable_entity  
        end
      else
        message = {message: "Password incorrect"}
        render json: message, status: :unprocessable_entity  
      end  
    else 
      message = {message: "User with login: #{@login} does not exist"}
      render json: message, status: :unprocessable_entity
    end
  end
  
  def logout
    user_data = AuthentificationTokenService.decode_token(bearer_token)
    if user_data
      user = User.find_by(:login => user_data.first["login"])

      if (user && user.token.present? && user.unset(:token) )
        message = {message: "User successfully logged out"}
        render json: message, status: :ok
      else
        message = {message: "Something went wrong or user is not logged in"}
        render json: message, status: :unauthorized
      end
    else
      message = {message: "Unauthorized access attempted"}
      render json: message, status: :unauthorized
    end
  end

  private
  def user_auth_parameters
    params.permit(:login, :password, :remember_me)
  end
  
  def get_user_by_login
    @login = param_to_search(user_auth_parameters[:login])
    @user = User.find_by(:login => @login)
  end
end