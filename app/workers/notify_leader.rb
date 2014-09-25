class NotifyLeader
  include Sidekiq::Worker

  def perform(following_id)
    ActiveRecord::Base.connection_pool.with_connection do
      begin
        Following.find(following_id).notify_leader
      rescue ActiveRecord::RecordNotFound
      end
    end
  end
end
