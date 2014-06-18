class NotifyCommentFollowers
  include Sidekiq::Worker

  def perform(comment_id)
    ActiveRecord::Base.connection_pool.with_connection do
      Comment.find(comment_id).notify_users
    end
  end
end
