class ApplicationController < ActionController::API
  
  protected
  def except_data!(data, parameters = [:password_digest, :_id, :tokens, :activation_code])
    return data.as_json({except: parameters}).reverse_merge({id: data._id.to_s})
  end

  def set_paging
    @limit = params[:limit] ? params[:limit].to_i : 10
    @page = params[:page] ? params[:page].to_i : 1
    @offset = @page == 1 ? 0 : (@limit.to_i * @page.to_i) - @limit.to_i
  end

  def param_to_search(param)
    return CGI.unescape(param.to_s)
  end

  def bearer_token
    pattern = /^Bearer /
    header  = request.headers['Authorization']
    header.gsub(pattern, '') if header && header.match(pattern)
  end

  def decode_bearer_token!
    @user_data = AuthentificationTokenService.decode_token(bearer_token)
  end
  
  def user_confirmed?
    user = User.find_by(:login => @user_data.first["login"])
    unless (user.confirmed)
      render json: {message: MESSAGES[:need_confirmation]}, status: :not_acceptable and return
    end
  end

  def token_expired?
    @needs_refresh = false
    user = User.find_by(:login => @user_data.first["login"])
    if @user_data && Time.now.to_i >= @user_data.first["expires_in"].to_i
      unless cookies["refresh_token"].nil? || cookies["refresh_token"].empty?
        refresh_token = AuthentificationTokenService.decode_token(cookies["refresh_token"])
        if Time.now.to_i >= refresh_token.first["expires_in"].to_i
          user.set(tokens: user.tokens.as_json.filter{ |t| t != refresh_token })
          render json: {message: MESSAGES[:token_expired] }, status: :unauthorized_access and return
        else
          @needs_refresh = true
        end
      end
    end
  end

  def issue_tokens(user)
    refresh_token = AuthentificationTokenService.create_token(user, :refresh)
    access_token = AuthentificationTokenService.create_token(user, :access)

    if user.tokens.present?
      user.set(tokens: user.tokens << refresh_token) 
    else
      user.set(tokens: [refresh_token])
    end

    cookies["refresh_token"] = { value: refresh_token, httponly: true }
    return {
        access_token: access_token.to_s, 
    }
  end
end
