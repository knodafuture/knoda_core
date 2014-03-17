class InvitationActivityNotifier

  def self.deliver(invitation)  
    puts 'make activity'
    a = Activity.new
    a.user_id = invitation.recipient_user_id
    a.activity_type = 'INVITATION'
    a.invitation_code = invitation.code
    a.invitation_group_name =  invitation.group.name
    a.invitation_sender = invitation.user.username
    a.title = "#{invitation.user.username} has invited you to join the group \"#{invitation.group.name}\""
    a.created_at = DateTime.now
    a.seen = false
    a.save!
  end
end