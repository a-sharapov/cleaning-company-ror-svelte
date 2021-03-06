class AuthentificationTokenService
  HMAC_SECRET = ENV['SECRET_KEY']
  ALGORITHM_TYPE = "HS256"

  class << self
    def create_token(data, type, metrics = nil)
      return false unless data.present?
      expires_in = type.eql?(:refresh) ? (Time.now + 7.days).to_i : (Time.now + 15.minutes).to_i

      refresh_data = {
        login: data[:login],
        expires_in: expires_in,
        metrics: metrics,
      }

      access_data = refresh_data.merge(role: data[:role])

      return JWT.encode(access_data, HMAC_SECRET, ALGORITHM_TYPE) if type.eql?(:access)
      return JWT.encode(refresh_data, HMAC_SECRET, ALGORITHM_TYPE) if type.eql?(:refresh)
    end

    def decode_token(token)
      return false if token.nil? || token.empty?
      begin
        return JWT.decode(token, HMAC_SECRET)
      rescue
        return false
      end
    end

    def issue_tokens(user, metrics = nil)
      refresh_token = self.create_token(user, :refresh, metrics)
      access_token = self.create_token(user, :access, metrics)

      if user.tokens.present?
        user.set(tokens: user.tokens << refresh_token) 
      else
        user.set(tokens: [refresh_token])
      end

      return {
          refresh_token: refresh_token.to_s,
          access_token: access_token.to_s, 
      }
    end

    def reissue_access_token(user, metrics = nil)
      return self.create_token(user, :access, metrics)
    end

    def expired?(token) 
      token_data = self.decode_token(token)
      return Time.now.to_i > token_data.first["expires_in"].to_i
    end

    def clear_expired_tokens(user) 
      user.set(tokens: user.tokens.as_json.filter{ |token| !self.expired?(token) }) if user.tokens.present?
    end
  end
end
