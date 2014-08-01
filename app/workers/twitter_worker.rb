class TwitterWorker
  include Sidekiq::Worker
  @queue = :twitter

  def perform(user_id, prediction_id, brag)
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find(user_id)
      account = user.twitter_account
      prediction = Prediction.find(prediction_id)

      unless account
        return;
      end

      s3_object_path = prediction.shareable_image.path
      s3_object_path[0] = ''
      unless prediction.shareable_image && AWS::S3.new.buckets[ENV['S3_BUCKET_NAME']].objects[s3_object_path].exists?
        raise "Prediction_Image_Not_Ready"
        return
      end

      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.config.twitter_key
        config.consumer_secret     = Rails.application.config.twitter_secret
        config.access_token        = account.access_token
        config.access_token_secret = account.access_token_secret
      end
      if brag
        if (prediction.user.id == user.id)
          message = trim_message "I won my prediction: #{prediction.body}", "via @KNODAfuture #{prediction.short_url}"
        else
          if (prediction.is_right)
            message = trim_message "I agreed and won: #{prediction.body}", "via @KNODAfuture #{prediction.short_url}"
          else
            message = trim_message "I disagreed and won: #{prediction.body}", "via @KNODAfuture #{prediction.short_url}"
          end
        end
      else
        message = trim_message prediction.body, "via @KNODAfuture #{prediction.short_url}"
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
