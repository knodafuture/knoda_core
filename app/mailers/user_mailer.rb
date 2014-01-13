class UserMailer < ActionMailer::Base
  require 'mail'
  address = Mail::Address.new "support@knoda.com"
  address.display_name = "Knoda"    
  default from: address.format

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.signup.subject
  #
  def signup(user)
    @resource = user

    mail to: user.email
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.email_was_changed.subject
  #
  def email_was_changed(user)
    @resource = user

    mail to: user.email
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.username_was_changed.subject
  #
  def username_was_changed(user)
    @resource = user

    mail to: user.email
  end
end
