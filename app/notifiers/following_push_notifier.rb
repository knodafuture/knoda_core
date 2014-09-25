class FollowingPushNotifier

  def self.deliver(following)
    recipient = following.leader
    android_devices = recipient.android_device_tokens
    ios_devices = recipient.apple_device_tokens.where(sandbox: Rails.application.config.apns_sandbox)
    message = following.push_text
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
            :id => following.user_id,
            :type => 'f'
          }
        )
        pusher.push(notification)
      end
    end
    if android_devices.size > 0
      gcm = GCM.new("AIzaSyDSuv3FpA4NtTXJivbsfh28vixLn55DrlI")
      response = gcm.send_notification(recipient.android_device_tokens.pluck(:token), {data: {alert: message, id: following.user_id, type: 'f'}});
    end
  end
end
