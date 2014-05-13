class FacebookWorker
  include Sidekiq::Worker
  @queue = :facebook

  def perform(user_id, prediction_id)
    ActiveRecord::Base.connection_pool.with_connection do
      user = User.find(user_id)
      account = user.facebook_account
      prediction = Prediction.find(prediction_id)
      unless account
        return;
      end

      unless prediction.shareable_image
        FacebookWorker.perform_async(user_id,prediction_id)
        return
      end

      graph = Koala::Facebook::API.new(account.access_token)
      graph.put_connections("me", "knodafacebook:share", :prediction => "#{Rails.application.config.knoda_web_url}/predictions/#{prediction_id}/share")
    end
  end
end
