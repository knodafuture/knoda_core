class TwitterWorker
  include Sidekiq::Worker
  @queue = :twitter

  def perform(user_id, prediction_id)
    puts "PERFORM TWITTER"
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find(user_id)
      account = user.twitter_account
      prediction = Prediction.find(prediction_id)

      unless account
        return;
      end

      unless prediction.shareable_image
        TwitterWorker.perform_async(user_id,prediction.id)
        return
      end

      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.config.twitter_key
        config.consumer_secret     = Rails.application.config.twitter_secret
        config.access_token        = account.access_token
        config.access_token_secret = account.access_token_secret
      end

      message = trim_message prediction.body, " via @KNODAfuture #{prediction.short_url}"
      client.update(message)

    end
  end


  def trim_message message, suffix
    max = 140 - suffix.length
    if message.length >= max
      message = message[0..max-2]
    end
    puts "#{message} #{suffix}"
    return "#{message} #{suffix}"
  end
end
