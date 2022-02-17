class ApplicationMailer < ActionMailer::Base
  default from: 'web@a-sharapov.com'
  layout 'mailer'

  def activation_email
    @data = params[:data]
    @email, @login, @code = @data["email"].to_s, @data["login"].to_s, @data["activation_code"].to_s
    @url  = 'http://localhost/activation?code=' + @code
    mail(to: @email, subject: 'Activation link')
  end

  def new_password
    @data = params[:data]
    @email, @login, @password = @data["email"].to_s, @data["login"].to_s, @data[:new_password]
    mail(to: @email, subject: 'New password')
  end
end
