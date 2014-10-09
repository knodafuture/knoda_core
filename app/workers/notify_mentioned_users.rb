class NotifyMentionedUsers
  include Sidekiq::Worker

  def perform(id, mentionType)
    ActiveRecord::Base.connection_pool.with_connection do
      begin
        if mentionType == 'PREDICTION'
          Prediction.find(id).notify_mentioned_users
        else
          Comment.find(id).notify_mentioned_users
        end
      rescue ActiveRecord::RecordNotFound
      end
    end
  end
end
