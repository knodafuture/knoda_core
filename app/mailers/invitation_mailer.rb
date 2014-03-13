class InvitationMailer < MandrillMailer::TemplateMailer
  default from: 'support@knoda.com'

  def inv(invitation)
    user = invitation.user
    to = ''
    if invitation.recipient_email
      to = invitation.recipient_email
    else
      to = User.find(invitation.recipient_user_id).email
    end
    mandrill_mail template: 'group-invitation',
      to: {email: to},
      vars: {
        'USERNAME' => invitation.user.username,
        'GROUPNAME' => invitation.group.name,
        'JOIN_URL' => "#{invitation.invitation_link}"
      },
      important: true,
      inline_css: true    
  end
end