class OutcomePushNotifier

  def self.deliver(challenge)
    recipient = challenge.user
    android_devices = recipient.android_device_tokens
    ios_devices = recipient.apple_device_tokens.where(sandbox: Rails.application.config.apns_sandbox)

    message = challenge.push_outcome_text

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
            :id => challenge.prediction.id,
            :type => 'p'
          }
        )
        pusher.push(notification)
      end
    end
    if android_devices.size > 0
      gcm = GCM.new("AIzaSyDSuv3FpA4NtTXJivbsfh28vixLn55DrlI")
      response = gcm.send_notification(android_devices.pluck(:token), {data: {alert: message, id: challenge.prediction.id, type: 'p'}});
    end
  end
end
