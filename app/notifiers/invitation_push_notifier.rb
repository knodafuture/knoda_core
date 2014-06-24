class InvitationPushNotifier

  def self.deliver(invitation)
    pusher = Grocer.pusher(
          certificate: Rails.application.config.apns_certificate,
          gateway:     Rails.application.config.apns_gateway,
          port:        2195,
          retries:     3
        )
    gcm = GCM.new("AIzaSyDSuv3FpA4NtTXJivbsfh28vixLn55DrlI")
    sender = User.find(invitation.user_id)
    recipient = User.find(invitation.recipient_user_id)
    group = Group.find(invitation.group_id)
    message = "Hey-O! #{sender.username} has invited you to join the group \"#{group.name}\""
    recipient.apple_device_tokens.where(sandbox: Rails.application.config.apns_sandbox).each do |token|
      notification = Grocer::Notification.new(
        device_token:      token.token,
        alert:             message,
        badge:             recipient.alerts_count,
        custom: {
          "id": invitation.code,
          "type": 'gic'
        }
      )
      pusher.push(notification)
    end
    if recipient.android_device_tokens.size > 0
      response = gcm.send_notification(recipient.android_device_tokens.pluck(:token), {data: {alert: message, id: invitation.code, type: 'gic'}});
    end
  end
end
