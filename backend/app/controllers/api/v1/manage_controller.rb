class Api::V1::ManageController < ApplicationController

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
  
  private
  def hasAccess?
    get_tokens
    check_auth!
    @user = User.find_by(login: AuthentificationTokenService.decode_token(get_tokens[:access_token]).first["login"])
    escape_with!(:auth, :unauthorized_access, :unauthorized) if @user.banned.eql?(true) || !is_manager?(@user)
  end
end
