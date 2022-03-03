class ApplicationController < ActionController::API
  include ActionController::Cookies

  protected
  def except_data!(data, parameters = [
    :_id, 
    :password_digest, 
    :tokens, 
    :activation_code, 
    :wrong_attempts_count, 
    :blocked_until, 
    :user_id, 
    :company_profile_id, 
    ])
    return data.as_json({except: parameters})
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

  def escape_with!(block, message, type, assets = nil)
    raise ApiError.new(ApiError::MESSAGES[block][message], type, assets)
  end

  def render_api_error(e)
    message = {message: e.message}
    message = {message: e.message, assets: e.assets} unless e.assets.nil?
    render json: message, status: e.type and return
  end

  def render_data(data)
    render json: except_data!(data), status: :ok and return
  end
  
  def get_tokens
    return false unless cookies["refresh_token"].present?
    return false unless bearer_token.present?
    return {
      access_token: bearer_token,
      refresh_token: cookies["refresh_token"],
    }
  end

  def get_tokens_refresh_token
    return false unless cookies["refresh_token"].present?
    return cookies["refresh_token"]
  end

  def check_auth!
    begin
      escape_with!(:token, :not_set, :ok) unless get_tokens
      access_token = get_tokens[:access_token]
      escape_with!(:auth, :unauthorized_access, :ok) unless AuthentificationTokenService.decode_token(access_token)
      escape_with!(:auth, :unauthorized_access, :ok) if AuthentificationTokenService.expired?(access_token)
    end
  end

  def user_from_token
    AuthentificationTokenService.decode_token(get_tokens[:access_token]).first["login"]
  end

  def is_manager?(user)
    user.role.eql?("manager")
  end

  def check_access!(user)
    begin
      escape_if_in_blacklist(user)
      escape_with!(:auth, :forbidden, :ok) unless is_manager?(user) || user.login.eql?(AuthentificationTokenService.decode_token(get_tokens[:access_token]).first["login"])
    end
  end

  def escape_if_in_blacklist(user)
    escape_with!(:management, :banned, :ok, user.blacklist.description.to_s) if user.banned.eql?(true)
  end

  def generate_new_password
    o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
    return (0...12).map { o[rand(o.length)] }.join
  end
  
  def notify_handler(data, type, deliver = :deliver_now)
    begin
      unless data["phone"].nil?
        TwilioNotifyService.send(data, type)
      end
      unless data["email"].nil?
        ApplicationMailer.with(data: data).method(type).call.method(deliver).call
      end
      return true
    rescue
      return false
    end
  end

  def except_all(data)
    data.map do |e|
      except_data!(e)
    end
  end

  def prepare_user!
    begin
      check_auth!
      user = User.find_by(login: user_from_token)
      escape_with!(:user, :not_exist, :ok) unless user
      check_access!(user)
      return user
    end
  end
end
