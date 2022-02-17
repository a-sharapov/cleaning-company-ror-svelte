class TwilioNotifyService
  require "twilio-ruby"

  class << self
    def send(data, type)
      @client = Twilio::REST::Client.new(ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"])
      @login, @phone, @code, @password = data["login"].to_s, data["phone"].to_s, data["activation_code"].to_s, data[:new_password].to_s

      sms = {
        activation_email: "Привет, #{@login}, это Марафеткина! Активируй свой аккаунт по ссылке: http://#{ENV['HOST_NAME']}/activation?code=#{@code}",
        new_password: "Привет, #{@login}, это Марафеткина! Твой новый пароль для доступа в личный кабинет #{@password}",
      }

      begin
        @client.messages.create(:to => "+" + @phone, :from => ENV["TWILIO_NUMBER"], :body => sms[type])
      rescue
        return false
      end
    end
  end
end
