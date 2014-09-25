class TwitterInviteWorker
  include Sidekiq::Worker

  def perform(user_id, msg=nil)
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find(user_id)
      account = user.twitter_account
      unless account
        return;
      end

      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.config.twitter_key
        config.consumer_secret     = Rails.application.config.twitter_secret
        config.access_token        = account.access_token
        config.access_token_secret = account.access_token_secret
      end
      if msg
        message = trim_message(msg, " via @KNODAfuture #{Rails.application.config.knoda_web_url}")
      else
        message = "I'm on Knoda. Start following me to see all of my predictions. via @KNODAfuture #{Rails.application.config.knoda_web_url}"
      end
      client.update(message)
    end
  end

  def trim_message message, suffix
    max = 137 - suffix.length
    if message.length >= max
      message = message[0..max-5]
      return "#{message}... #{suffix}"
    end
    return "#{message} #{suffix}"
  end

end
