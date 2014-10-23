class MarketingPush
  include Sidekiq::Worker

  def perform(params)
    ActiveRecord::Base.connection_pool.with_connection do
      puts params
      message = params['bodyinput']

      #if one user
      if params['userinput'] != ""
        @user=User.where(["lower(username) = :username", {:username => params['userinput'].downcase }]).first
        if params['pushtype'] == "Android" or params['pushtype'] == "All"
          gcm = GCM.new("AIzaSyDSuv3FpA4NtTXJivbsfh28vixLn55DrlI")
          response = gcm.send_notification(@user.android_device_tokens.pluck(:token), {data: {alert: message, type: 'm'}});
        elsif params['pushtype'] == "iOS" or params['pushtype'] == "All"

        end
      elsif params['contestinput'] != ""
        @contest= Contest.where(["id = :id",{:id => params['contestinput']}])
        if params['pushtype'] == "Android" or params['pushtype'] == "All"

        elsif params['pushtype'] == "iOS" or params['pushtype'] == "All"

        end
      elsif params['pushtype']
        if params['pushtype'] == "Android" or params['pushtype'] == "All"

        elsif params['pushtype'] == "iOS" or params['pushtype'] == "All"

        end
      end
    end
  end
end
