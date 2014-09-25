class InvitationPushNotifier

  def self.deliver(invitation)
    sender = User.find(invitation.user_id)
    recipient = User.find(invitation.recipient_user_id)
    group = Group.find(invitation.group_id)
    message = "Hey-O! #{sender.username} has invited you to join the group \"#{group.name}\""
    ios_devices = recipient.apple_device_tokens.where(sandbox: Rails.application.config.apns_sandbox)
    android_devices = recipient.android_device_tokens
    if ios_devices.size > 0
      pusher = Grocer.pusher(
        certificate: Rails.application.config.apns_certificate,
        gateway:     Rails.application.config.apns_gateway,
        port:        2195,
        retries:     3
      )
      ios_devices.each do |token|
        notification = Grocer::Notification.new(
          device_token:      token.token,
          alert:             message,
          badge:             recipient.alerts_count,
          custom: {
            :id => invitation.code,
            :type => 'gic'
          }
        )
        pusher.push(notification)
      end
    end
    if android_devices.size > 0
      gcm = GCM.new("AIzaSyDSuv3FpA4NtTXJivbsfh28vixLn55DrlI")
      response = gcm.send_notification(android_devices.pluck(:token), {data: {alert: message, id: invitation.code, type: 'gic'}});
    end
  end
end
