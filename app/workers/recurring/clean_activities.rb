class Recurring::CleanActivities
  include Sidekiq::Worker

  def perform
    ActiveRecord::Base.connection_pool.with_connection do
      Activity.where(:seen => true, :activity_type => ['WON','LOST','COMMENT','PREDICTION_MENTION','COMMENT_MENTION']).where('created_at < ?', DateTime.now - 60.days).delete_all
    end
  end
end
