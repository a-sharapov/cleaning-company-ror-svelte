class Api::V1::ManagementController < ApplicationController

  def index
     begin
      hasAccess?
      render json: {
        message: "Access granted", 
      }, status: :ok and return
     rescue ApiError => e
      render_api_error(e)
     end
  end

  def ban
    begin
      user = User.find_by(login: ban_parameters[:login])
      escape_with!(:user, :not_exist, :not_found) unless user
      escape_with!(:management, :banned, :not_acceptable) unless user.banned.eql?(false)
      escape_with!(:user, :not_update, :not_acceptable) unless user.set(banned: true)
      banned = Blacklist.new(ban_parameters)
      banned.user = user
      escape_with!(:user, :invalid_request, :unprocessable_entity, banned.errors.full_messages) unless banned.valid?
      escape_with!(:user, :not_update, :unprocessable_entity, banned.errors.full_messages) unless banned.save
      render json: {
        message: "User #{user.login} has been banned", 
      }, status: :ok and return
    rescue ApiError => e
      render_api_error(e)
    end
  end
  
  private
  def ban_parameters
    params.permit(:login, :description)
  end

  def hasAccess?
    get_tokens
    check_auth!
    @user = User.find_by(login: AuthentificationTokenService.decode_token(get_tokens[:access_token]).first["login"])
    escape_with!(:auth, :unauthorized_access, :unauthorized) if @user.banned.eql?(true) || !is_manager?(@user)
  end
end
