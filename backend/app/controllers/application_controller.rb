class ApplicationController < ActionController::API
  include ActionController::Cookies
  require "twilio-ruby"

  protected
  def except_data!(data, parameters = [:_id, :password_digest, :tokens, :activation_code])
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
    message = {message: e.message, errors: e.assets} unless e.assets.nil?
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
    escape_with!(:token, :not_set, :unprocessable_entity) unless get_tokens
    escape_with!(:auth, :unauthorized_access, :unauthorized) unless AuthentificationTokenService.decode_token(get_tokens[:access_token])
    escape_with!(:auth, :unauthorized_access, :unauthorized) if AuthentificationTokenService.expired?(get_tokens[:access_token])
  end

  def check_access!(user)
    escape_with!(:auth, :unauthorized_access, :unauthorized) unless user.role.eql?("manager") || user.login.eql?(AuthentificationTokenService.decode_token(get_tokens[:access_token]).first["login"])
  end

  def generate_new_password
    o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
    return (0...12).map { o[rand(o.length)] }.join
  end
  
  def notify_handler(data, type, deliver = :deliver_now)
    begin
      if data["phone"].present? && !data["phone"].phone.nil?
        
        # SMS twilio
      end
      if data["email"].present? && !data["email"].nil?
        ApplicationMailer.with(data: data).method(type).call.method(deliver).call
      end
      return true
    rescue
      return false
    end
  end
end
