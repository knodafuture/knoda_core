class CommentPushNotifier

  def self.deliver(comment, recipient, is_owner)
    pusher = Grocer.pusher(
      certificate: Rails.application.config.apns_certificate,
      gateway:     Rails.application.config.apns_gateway,
      port:        2195,
      retries:     3
    )
    gcm = GCM.new("AIzaSyDSuv3FpA4NtTXJivbsfh28vixLn55DrlI")
    message = comment.to_push_text(is_owner)
    recipient.apple_device_tokens.where(sandbox: Rails.application.config.apns_sandbox).each do |token|
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
    if recipient.android_device_tokens.size > 0
      response = gcm.send_notification(recipient.android_device_tokens.pluck(:token), {data: {alert: message, id: comment.prediction.id, type: 'p'}});
    end
  end
end
