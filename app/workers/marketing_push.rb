class MarketingPush
  include Sidekiq::Worker

  def perform(params)
    ActiveRecord::Base.connection_pool.with_connection do
      @gcm = GCM.new("AIzaSyDSuv3FpA4NtTXJivbsfh28vixLn55DrlI")
      puts params
      message = params['bodyinput']

      #if one user
      if params['userinput'] != ""
        @user=User.where(["lower(username) = :username", {:username => params['userinput'].downcase }]).first
        if params['pushtype'] == "Android" or params['pushtype'] == "All"
          send_android(@user, message)
        end
        if params['pushtype'] == "iOS" or params['pushtype'] == "All"
          send_ios(@user, message)
        end
      elsif params['contestinput'] != ""
        @contest= Contest.where(:id => params['contestinput'])
        Contest.leaderboard(self).each do |l|
          user = User.find(l[:user_id])
          if params['pushtype'] == "Android" or params['pushtype'] == "All"
            send_android(user, message)
          end
          if params['pushtype'] == "iOS" or params['pushtype'] == "All"
            send_ios(user, message)
          end
        end
      elsif params['pushtype']
        User.all.each do |user|
          if params['pushtype'] == "Android" or params['pushtype'] == "All"
            send_android(user, message)
          end
          if params['pushtype'] == "iOS" or params['pushtype'] == "All"
            send_ios(user, message)
          end
        end
      end
    end
  end

private
  def send_android(recipient, message)
    response = @gcm.send_notification(recipient.android_device_tokens.pluck(:token), {data: {alert: message, type: 'm'}});
  end

  def send_ios(recipient, message)
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
            "type" => 'm'
          }
        )
        x = pusher.push(notification)
      end
    end
  end
end
