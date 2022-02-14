class ApplicationController < ActionController::API
  include ActionController::Cookies

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
    @access_token_data = AuthentificationTokenService.decode_token(bearer_token)
  end

  def render_api_error(message, type)
    render json: {error: message}, status: type and return
  end
  
  def get_tokens
    false unless cookies["refresh_token"].present? || cookies["refresh_token"].nil?
    false unless bearer_token.present? || bearer_token.nil?
    refresh_token = cookies["refresh_token"]
    access_token = bearer_token

    {
      access_token: access_token,
      refresh_token: refresh_token,
    }
  end

  def expired?(token)
    token_data = AuthentificationTokenService.decode_token(token)
    false if !token_data.present? || token_data.empty? || token_data.nil?
    false if Time.now.to_i >= token_data.first["expires_in"].to_i
    true
  end
end
