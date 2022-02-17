class ApplicationMailer < ActionMailer::Base
  default from: 'web@a-sharapov.com'
  layout 'mailer'

  def activation_email
    @data = params[:data]
    @hostname, @email, @login, @code = ENV["HOSTNAME"], @data["email"].to_s, @data["login"].to_s, @data["activation_code"].to_s
    @url  = 'http://#{@hostname}/activation?code=' + @code
    mail(to: @email, subject: 'Activation link')
  end

  def new_password
    @data = params[:data]
    @email, @login, @password = @data["email"].to_s, @data["login"].to_s, @data[:new_password].to_s
    mail(to: @email, subject: 'New password')
  end
end
