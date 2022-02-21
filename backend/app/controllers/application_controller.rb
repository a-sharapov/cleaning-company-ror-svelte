class ApplicationController < ActionController::API
  include ActionController::Cookies

  protected
  def except_data!(data, parameters = [:_id, :password_digest, :tokens, :activation_code, :wrong_attempts_count, :blocked_until])
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
  
  def get_tokens
    return false unless cookies["refresh_token"].present?
    return false unless bearer_token.present?
    return {
      access_token: bearer_token,
      refresh_token: cookies["refresh_token"],
    }
  end

  def check_auth!
    begin
      escape_with!(:token, :not_set, :unprocessable_entity) unless get_tokens
      escape_with!(:auth, :unauthorized_access, :unauthorized) unless AuthentificationTokenService.decode_token(get_tokens[:access_token])
      escape_with!(:auth, :unauthorized_access, :unauthorized) if AuthentificationTokenService.expired?(get_tokens[:access_token])
    end
  end

  def is_manager?(user)
    user.role.eql?("manager")
  end

  def check_access!(user)
    begin
      escape_with!(:auth, :service_unavailable, :service_unavailable, user.blacklist.description.to_s) if user.banned.eql?(true)
      escape_with!(:auth, :forbidden, :forbidden) unless is_manager?(user) || user.login.eql?(AuthentificationTokenService.decode_token(get_tokens[:access_token]).first["login"])
    end
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
end
