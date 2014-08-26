class NotifyLeader
  include Sidekiq::Worker

  def perform(following_id)
    ActiveRecord::Base.connection_pool.with_connection do
      Following.find(following_id).notify_leader
    end
  end
end
