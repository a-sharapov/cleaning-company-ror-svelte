class Api::V1::AuthentificationController < ApplicationController
  before_action :get_user_by_login, only: [:login]
  before_action :set_metrics, only: [:login, :refresh, :confirm]
  before_action :get_tokens, only: [:refresh]

  include ActionController::Cookies

  def login
    begin
      @wrong_attempts_count = ENV["WRONG_ATTEMPTS_COUNT"] ? ENV["WRONG_ATTEMPTS_COUNT"].to_i : 3
      escape_with!(:api, :wrong_request, :ok) unless user_login_parameters.present?
      escape_with!(:user, :not_exist, :ok) unless @user
      escape_with!(:auth, :need_confirmation, :ok) unless @user.confirmed
      escape_if_in_blacklist(@user)


      if @user.authenticate(user_login_parameters[:password]) && @user.blocked_until < Time.now
        @user.update(wrong_attempts_count: 0)
      end
      unless @user.wrong_attempts_count.to_i < @wrong_attempts_count
        @user.update(blocked_until: Time.now + 1.hour) unless @user.blocked_until.present?
        escape_with!(:auth, :blocked_until, :ok, "Начиная с #{Time.parse(@user.blocked_until.to_s).in_time_zone('Europe/Minsk')}")
      end
      unless @user.authenticate(user_login_parameters[:password])
        @user.update(wrong_attempts_count: @user.wrong_attempts_count.to_i + 1)
        remaining_attempts = @wrong_attempts_count - @user.wrong_attempts_count.to_i + 1
        escape_with!(:auth, :password_incorrect, :ok, "Вы можете попробовать авторизоваться ещё #{remaining_attempts} раз(а)")
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
      refresh_token = get_tokens_refresh_token
      escape_with!(:auth, :unauthorized_access, :ok) unless refresh_token_data = AuthentificationTokenService.decode_token(refresh_token)
      user = User.find_by(login: refresh_token_data.first["login"])
      escape_with!(:user, :not_exist, :ok) unless user
      escape_with!(:token, :missmatching, :ok) unless !user.tokens.empty? && user.tokens.filter{|t| t == refresh_token}.length > 0
      escape_with!(:auth, :not_logout, :ok) unless user.set(tokens: user.tokens.as_json.filter{ |t| t != refresh_token })
      
      AuthentificationTokenService.clear_expired_tokens(user)
      render json: {message: "Вы успешно вышли из системы"}, status: :ok
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def confirm
    begin
      escape_with!(:api, :wrong_request, :ok) if !user_confirmation_params[:code].present? || user_confirmation_params[:code].nil?
      user = User.find_by(:activation_code => user_confirmation_params[:code])
      escape_with!(:user, :not_exist, :ok) unless user
      escape_with!(:auth, :already_confirmed, :ok) if user.confirmed.eql?(true)
      escape_if_in_blacklist(user)
      escape_with!(:auth, :not_confirmed, :ok) unless user.set(confirmed: true) 
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
      refresh_token = get_tokens_refresh_token
      escape_with!(:auth, :unauthorized_access, :ok) unless refresh_token_data = AuthentificationTokenService.decode_token(refresh_token)
      user = User.find_by(login: refresh_token_data.first["login"])
      escape_with!(:user, :not_exist, :ok) unless user 
      escape_with!(:auth, :unauthorized_access, :ok) unless user.tokens.any? && user.tokens.find(refresh_token).any?
      escape_with!(:auth, :not_update, :ok) unless user.set(tokens: user.tokens.as_json.filter{ |t| t != refresh_token })
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
      escape_with!(:user, :not_exist, :ok) unless user 
      escape_if_in_blacklist(user)
      new_password = generate_new_password
      data = user.as_json.merge({new_password: new_password})
      escape_with!(:auth, :not_update, :ok) unless user.update(password: new_password)
      escape_with!(:api, :new_password_send_failure, :ok) unless notify_handler(data, :new_password)
      user.update({wrong_attempts_count: 0, blocked_until: Time.now})
      render json: {message: ApiError::MESSAGES[:user][:new_password]}, status: :ok
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def remove
    begin
      token_part = params[:id]
      user = prepare_user!
      escape_with!(:user, :not_exist, :ok) unless user
      escape_with!(:token, :missmatching, :ok) unless !user.tokens.empty? && user.tokens.filter{ |t| t.include?(token_part) }.length > 0
      escape_with!(:auth, :not_logout, :ok) unless user.set(tokens: user.tokens.as_json.filter{ |t| t.exclude?(token_part) })
      render json: {message: "Сессия была удалена", active_sessions: user.tokens.as_json}, status: :ok
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
