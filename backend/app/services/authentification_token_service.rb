class AuthentificationTokenService
  HMAC_SECRET = "cl34nING!"
  ALGORITHM_TYPE = "HS256"

  class << self
    def create_token(user, type)
      return false unless user.present?
      expires_in = (Time.now + 60*15).to_i if type.eql?(:access)
      expires_in = (Time.now + 3600*8).to_i if type.eql?(:refresh)

      payload = { 
        login: user.login,
        role: user.role,
        confirmed: user.confirmed,
        expires_in: expires_in,
      }

      JWT.encode(payload, HMAC_SECRET, ALGORITHM_TYPE)
    end

    def decode_token(token)
      return false if token.nil? || token.empty?
      return JWT.decode(token, HMAC_SECRET)
    end

    def update_token(user)
      return self.create_token(user)
    end
  end
end