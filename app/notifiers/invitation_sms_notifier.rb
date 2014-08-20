require 'rubygems'
require 'twilio-ruby'

class InvitationSmsNotifier

  def self.deliver(invitation)
    account_sid = Rails.application.config.twilio[:sid]
    auth_token = Rails.application.config.twilio[:token]
    @client = Twilio::REST::Client.new account_sid, auth_token
    if invitation.group_id
      msg = InvitationSmsNotifier.group_message(User.find(invitation.user_id).username, Group.find(invitation.group_id).name, invitation.invitation_link)
    else
      msg = InvitationSmsNotifier.join_message(User.find(invitation.user_id).username, invitation.invitation_link)
    end
    sms = @client.account.sms.messages.create(:body => msg,
        :to => invitation.recipient_phone,
        :from => Rails.application.config.twilio[:from])
  end

  def self.group_message(senderName, groupName, invitationLink)
    return "#{senderName} has invited you to join the group \"#{groupName}\". #{invitationLink}"
  end

  def self.join_message(senderName, invitationLink)
    return "#{senderName} has invited you to join Knoda. #{invitationLink}"
  end
end
