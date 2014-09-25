class FacebookWorker
  include Sidekiq::Worker

  def perform(user_id, prediction_id, brag=false)
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find(user_id)
      account = user.facebook_account
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

      graph = Koala::Facebook::API.new(account.access_token)
      if brag
        if (prediction.user.id == user.id)
          prefix = "I won my prediction:"
        else
          if (prediction.is_right)
            prefix = "I agreed and won:"
          else
            prefix = "I disagreed and won:"
          end
        end
        h = { :brag => true, :prefix => prefix}
        graph.put_connections("me", "knodafacebook:share", :prediction => "#{Rails.application.config.knoda_web_url}/predictions/#{prediction_id}/share?#{h.to_param}")
      else
        graph.put_connections("me", "knodafacebook:share", :prediction => "#{Rails.application.config.knoda_web_url}/predictions/#{prediction_id}/share")
      end
    end
  end
end
