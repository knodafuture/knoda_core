class NotifyExpiredPredictionsWorker
  include Sidekiq::Worker

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      pusher = Grocer.pusher(
        certificate: Rails.application.config.apns_certificate,
        gateway:     Rails.application.config.apns_gateway,
        port:        2195,
        retries:     3
      )
      gcm = GCM.new("AIzaSyDSuv3FpA4NtTXJivbsfh28vixLn55DrlI")

      predictions = Prediction.unnotified.readyForResolution
      predictions.each do |p|
        if p.user.notification_settings.where(:setting => 'PUSH_EXPIRED').first.active == true
          p.user.apple_device_tokens.where(sandbox: Rails.application.config.apns_sandbox).each do |token|
            notification = Grocer::Notification.new(
              device_token:      token.token,
              alert:             "Showtime! Your prediction has expired, settle it.",
              badge:             p.user.alerts_count,
              custom: {
                :id => p.id,
                :type => 'p'
              }
            )
            pusher.push(notification)
          end
          if p.user.android_device_tokens.size > 0
            response = gcm.send_notification(p.user.android_device_tokens.pluck(:token), {data: {alert: "You have predictions ready for resolution", id: p.id, type: 'p'}, collapse_key: "expired_predictions"});
          end
        end
        p.user.predictions.expired.unnotified.update_all(push_notified_at: DateTime.now)
      end
    end
  end
end
