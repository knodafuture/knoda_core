class InvitationMailer < ActionMailer::Base
  require 'mail'
  address = Mail::Address.new "support@knoda.com"
  address.display_name = "Knoda"    
  default from: address.format

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.signup.subject
  #
  def existing_user(invitation)
    @invitation = invitation
    user = User.find(invitation.recipient_user_id)
    mail to: user.email, from: invitation.user.email
  end

  def new_user(invitation)
    @invitation = invitation
    mail to: invitation.recipient_email, from: invitation.user.email
  end  
end
