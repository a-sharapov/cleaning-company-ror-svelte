class AuthentificationTokenService
  HMAC_SECRET = "cl34nING!"
  ALGORITHM_TYPE = "HS256"

  class << self
    def create_token(data, type)
      return false unless data.present?
      expires_in = (Time.now + 15.minutes).to_i if type.eql?(:access)
      expires_in = (Time.now + 7.day).to_i if type.eql?(:refresh)

      refresh_data = {
        login: data[:login],
        expires_in: expires_in,
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
  end
end