class Api::V1::ManagementController < ApplicationController

  def index
     begin
      hasAccess?
      token_data = AuthentificationTokenService.decode_token(get_tokens[:access_token])
      render json: {
        message: "Access granted, #{AuthentificationTokenService.expired?(get_tokens[:access_token])}", 
      }, status: :ok and return
     rescue ApiError => e
      render_api_error(e)
     end
  end

  def ban
    begin
      hasAccess?
      user = User.find_by(login: ban_parameters[:login])
      escape_with!(:user, :not_exist, :not_found) unless user
      escape_with!(:management, :banned, :not_acceptable) unless user.banned.eql?(false)
      escape_with!(:user, :not_update, :not_acceptable) unless user.set(banned: !user.banned)
      banned = Blacklist.find_or_create_by(login: ban_parameters[:login])
      banned.description = ban_parameters[:description]
      banned.user = user
      escape_with!(:user, :invalid_request, :unprocessable_entity, banned.errors.full_messages) unless banned.valid?
      escape_with!(:user, :not_update, :unprocessable_entity, banned.errors.full_messages) unless banned.save
      
      if user.banned.eql?(true)
        notify_type = :banned
      end

      if user.banned.eql?(false)
        notify_type = :unbanned
      end
      escape_with!(:api, :notification_send_failure, :precondition_failed, user.activation_code) unless notify_handler(user.as_json.merge({reason: banned.description}), notify_type)

      render json: {
        message: "User #{user.login} has been #{notify_type.to_s}",
      }, status: :ok and return
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def add
    begin
      key = add_parameters[:key]
      escape_with!(:auth, :unauthorized_access, :unauthorized) unless key.eql?(ENV["SECRET_KEY"])
      user = User.find_by(login: add_parameters[:login])
      escape_with!(:user, :not_exist, :not_found) unless user
      escape_with!(:management, :banned, :not_acceptable) unless user.banned.eql?(false)
      escape_with!(:user, :not_update, :unprocessable_entity) unless user.set(role: "manager")
      render json: {message: "User #{user.login} has been added to admin list"}, status: :ok and return
    rescue ApiError => e
      render_api_error(e)
    end
  end
  
  
  private
  def add_parameters
    params.permit(:login, :key)
  end

  def ban_parameters
    params.permit(:login, :description)
  end

  def hasAccess?
    check_auth!
    @user = User.find_by(login: AuthentificationTokenService.decode_token(get_tokens[:access_token]).first["login"])
    escape_with!(:auth, :unauthorized_access, :unauthorized) if @user.banned.eql?(true) || !is_manager?(@user)
  end
end
