class InvitationActivityNotifier

  def self.deliver(invitation)
    a = Activity.new
    a.user_id = invitation.recipient_user_id
    a.activity_type = 'INVITATION'
    a.invitation_code = invitation.code
    a.invitation_group_name =  invitation.group.name
    if invitation.group.avatar_image
      a.image_url = invitation.group.avatar_image[:small]
    end
    a.invitation_sender = invitation.user.username
    a.created_at = DateTime.now
    a.seen = false
    a.save!
  end
end
