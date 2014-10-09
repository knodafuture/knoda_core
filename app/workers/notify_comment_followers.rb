class NotifyCommentFollowers
  include Sidekiq::Worker

  def perform(comment_id)
    ActiveRecord::Base.connection_pool.with_connection do
      begin
        Comment.find(comment_id).notify_users
      rescue ActiveRecord::RecordNotFound
      end
    end
  end
end
