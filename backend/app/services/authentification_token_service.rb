class AuthentificationTokenService
  HMAC_SECRET = "cl34nING!"
  ALGORITHM_TYPE = "HS256"

  class << self
    def create_token(user)
      return false unless user.present?
      payload = { 
        login: user.login,
        role: user.role,
        expires_in: (Time.now + 3600*8).to_i
      }

      JWT.encode(payload, HMAC_SECRET, ALGORITHM_TYPE)
    end

    def decode_token(token)
      return false if token.nil? || token.empty?
      return JWT.decode(token, HMAC_SECRET)
    end

    def update_token(user)
      #updated_token = create_token(user)
    end
  end
end