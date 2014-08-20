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
    if invitation.group_id
      template = 'group-invitation'
      vars = {
        'USERNAME' => invitation.user.username,
        'GROUPNAME' => invitation.group.name,
        'JOIN_URL' => "#{invitation.invitation_link}"
      }
    else
      template = 'general-invitation'
      vars = {
        'USERNAME' => invitation.user.username,
        'JOIN_URL' => "#{invitation.invitation_link}"
      }
    end
    mandrill_mail template: template,
      from_name: 'Knoda',
      to: {email: to},
      vars: vars,
      important: true,
      inline_css: true
  end
end
