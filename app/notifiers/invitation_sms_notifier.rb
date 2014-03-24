require 'rubygems'
require 'twilio-ruby'

class InvitationSmsNotifier

  def self.deliver(invitation) 
    account_sid = Rails.application.config.twilio[:sid]
    auth_token = Rails.application.config.twilio[:token]
    @client = Twilio::REST::Client.new account_sid, auth_token
    msg = InvitationSmsNotifier.message(User.find(invitation.user_id).username, Group.find(invitation.group_id).name, invitation.invitation_link)
    sms = @client.account.sms.messages.create(:body => msg,
        :to => invitation.recipient_phone,
        :from => Rails.application.config.twilio[:from])
  end

  def self.message(senderName, groupName, invitationLink)
    return "#{senderName} has invited you to join the group \"#{groupName}\". #{invitationLink}"
  end
end