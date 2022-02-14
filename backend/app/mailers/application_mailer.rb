class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@marafetkina.space'
  layout 'mailer'

  def activation_email
    @user = params[:user]
    @login = @user.login
    @code = @user.activation_code
    @register_date = @user.created_at
    @url  = 'http://localhost/activation?code=' + @code
    mail(to: @user.email, subject: 'Activation link')
  end

  def new_password
    @user = params[:user]
    @password = params[:password]
    mail(to: @user.email, subject: 'New password')
  end
end
