class Api::V1::AuthentificationController < ApplicationController
  before_action :get_user_by_login, only: [:login]
  before_action :set_metrics, only: [:login, :refresh, :confirm]
  before_action :get_tokens, only: [:refresh]

  include ActionController::Cookies

  def login
    begin
      @wrong_attempts_count = ENV["WRONG_ATTEMPTS_COUNT"] ? ENV["WRONG_ATTEMPTS_COUNT"].to_i : 3
      escape_with!(:api, :wrong_request, :unprocessable_entity) unless user_login_parameters.present?
      escape_with!(:user, :not_exist, :not_found) unless @user
      escape_with!(:auth, :need_confirmation, :conflict) unless @user.confirmed
      escape_if_in_blacklist(@user)

      unless @user.wrong_attempts_count.to_i < @wrong_attempts_count
        @user.update(blocked_until: Time.now + 1.hour)
        escape_with!(:auth, :blocked_until, :forbidden)
      end
      unless @user.authenticate(user_login_parameters[:password])
        @user.update(wrong_attempts_count: @user.wrong_attempts_count.to_i + 1)
        remaining_attempts = @wrong_attempts_count - @user.wrong_attempts_count.to_i + 1
        escape_with!(:auth, :password_incorrect, :not_acceptable, "You can try again #{remaining_attempts} times")
      end

      if @user.authenticate(user_login_parameters[:password]) && @user.blocked_until < Time.now
        @user.update(wrong_attempts_count: 0)
      end
      
      tokens_pair = AuthentificationTokenService.issue_tokens(@user, @metrics)
      cookies["refresh_token"] = { value: tokens_pair[:refresh_token], httponly: true }
      response = {
        message: ApiError::MESSAGES[:auth][:login_in], 
        user: except_data!(@user).merge(
          access_token: tokens_pair[:access_token]
        )
      }
      render json: response, status: :ok
    rescue ApiError => e
      render_api_error(e)
    end
  end
  
  def logout
    begin
      check_auth!
      access_token = get_tokens[:access_token]
      refresh_token = get_tokens[:refresh_token]
      escape_with!(:auth, :unauthorized_access, :unauthorized) unless access_token_data = AuthentificationTokenService.decode_token(access_token)
      user = User.find_by(login: access_token_data.first["login"])
      escape_with!(:user, :not_exist, :not_found) unless user
      check_access!(user)
      escape_with!(:token, :missmatching, :not_acceptable) unless !user.tokens.empty? && user.tokens.filter{|t| t == refresh_token}.length > 0
      escape_with!(:auth, :not_logout, :unprocessable_entity) unless user.set(tokens: user.tokens.as_json.filter{ |t| t != refresh_token })
      
      AuthentificationTokenService.clear_expired_tokens(user)
      message = {message: "User successfully logged out"}
      render json: message, status: :ok
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def confirm
    begin
      escape_with!(:api, :wrong_request, :unprocessable_entity) if !user_confirmation_params[:code].present? || user_confirmation_params[:code].nil?
      user = User.find_by(:activation_code => user_confirmation_params[:code])
      escape_with!(:user, :not_exist, :not_found) unless user
      escape_with!(:auth, :already_confirmed, :ok) if user.confirmed.eql?(true)
      escape_if_in_blacklist(user)
      escape_with!(:auth, :not_confirmed, :unprocessable_entity) unless user.set(confirmed: true) 
      tokens_pair = AuthentificationTokenService.issue_tokens(user, @metrics)
      set_refresh_token(tokens_pair[:refresh_token])

      response = {
        message: ApiError::MESSAGES[:auth][:confirmed], 
        user: except_data!(user).merge(
          access_token: tokens_pair[:access_token]
        )
      }
      render json: response, status: :ok
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def refresh
    begin
      check_auth!
      access_token = get_tokens[:access_token]
      refresh_token = get_tokens[:refresh_token]
      escape_with!(:auth, :unauthorized_access, :unauthorized) unless access_token_data = AuthentificationTokenService.decode_token(access_token)
      user = User.find_by(login: access_token_data.first["login"])
      check_access!(user)
      escape_with!(:user, :not_exist, :not_found) unless user 
      escape_with!(:auth, :unauthorized_access, :unauthorized) unless user.tokens.any? && user.tokens.find(refresh_token).any?
      escape_with!(:auth, :not_update, :unprocessable_entity) unless user.set(tokens: user.tokens.as_json.filter{ |t| t != refresh_token })
      tokens_pair = AuthentificationTokenService.issue_tokens(user, @metrics)
      set_refresh_token(tokens_pair[:refresh_token])
      response = {
        message: ApiError::MESSAGES[:auth][:update], 
        user: except_data!(user).merge(
          access_token: tokens_pair[:access_token]
        )
      }
      render json: response, status: :ok
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def unlock
    begin
      user = User.find_by(activation_code: params[:code])
      escape_with!(:user, :not_exist, :not_found) unless user 
      escape_if_in_blacklist(user)
      new_password = generate_new_password
      data = user.as_json.merge({new_password: new_password})
      escape_with!(:api, :new_password_send_failure, :precondition_failed) unless notify_handler(data, :new_password)
      escape_with!(:auth, :not_update, :unprocessable_entity) unless user.update(password: new_password)
      user.update({wrong_attempts_count: 0, blocked_until: Time.now})
      render json: {message: ApiError::MESSAGES[:user][:new_password]}, status: :ok
    rescue ApiError => e
      render_api_error(e)
    end
  end

  private
  def set_metrics
    if request.remote_ip.nil? && request.user_agent.nil?
      @metrics = nil
    else 
      @metrics = {
        ip: request.remote_ip,
        agent: request.user_agent,
      }
    end
  end

  def set_refresh_token(token)
    cookies["refresh_token"] = { value: token, httponly: true }
  end

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
