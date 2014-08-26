class FollowingPushNotifier

  def self.deliver(following)
    pusher = Grocer.pusher(
          certificate: Rails.application.config.apns_certificate,
          gateway:     Rails.application.config.apns_gateway,
          port:        2195,
          retries:     3
        )
    gcm = GCM.new("AIzaSyDSuv3FpA4NtTXJivbsfh28vixLn55DrlI")
    recipient = following.leader
    message = following.push_text
    recipient.apple_device_tokens.where(sandbox: Rails.application.config.apns_sandbox).each do |token|
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
    if recipient.android_device_tokens.size > 0
      response = gcm.send_notification(recipient.android_device_tokens.pluck(:token), {data: {alert: message, id: following.user_id, type: 'f'}});
    end
  end
end
