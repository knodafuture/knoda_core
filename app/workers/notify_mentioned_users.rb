class NotifyMentionedUsers
  include Sidekiq::Worker

  def perform(prediction_id)
    ActiveRecord::Base.connection_pool.with_connection do
      begin
        Prediction.find(prediction_id).notify_mentioned_users
      rescue ActiveRecord::RecordNotFound
      end
    end
  end
end
