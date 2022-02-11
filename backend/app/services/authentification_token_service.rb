class AuthentificationTokenService
  HMAC_SECRET = "cl34nING!"
  ALGORITHM_TYPE = "HS256"

  class << self
    def create_token(data, type)
      return false unless data.present?
      expires_in = (Time.now + 3600).to_i if type.eql?(:access)
      expires_in = (Time.now + 86400*7).to_i if type.eql?(:refresh)

      refresh_data = {
        login: data[:login],
        ip: data[:ip],
        expires_in: expires_in,
      }

      access_data = refresh_data.merge(role: data[:role])

      return JWT.encode(access_data, HMAC_SECRET, ALGORITHM_TYPE) if type.eql?(:access)
      return JWT.encode(refresh_data, HMAC_SECRET, ALGORITHM_TYPE) if type.eql?(:refresh)
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