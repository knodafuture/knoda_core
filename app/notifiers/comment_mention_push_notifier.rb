class CommentMentionPushNotifier

  def self.deliver(comment, recipient)
    message = comment.to_mention_push_text()
    ios_devices = recipient.apple_device_tokens.where(sandbox: Rails.application.config.apns_sandbox)
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
            "id" => comment.prediction.id,
            "type" => 'p'
          }
        )
        x = pusher.push(notification)
      end
    end
    if recipient.android_device_tokens.size > 0
      gcm = GCM.new("AIzaSyDSuv3FpA4NtTXJivbsfh28vixLn55DrlI")
      response = gcm.send_notification(recipient.android_device_tokens.pluck(:token), {data: {alert: message, id: comment.prediction.id, type: 'p'}});
    end
  end
end
