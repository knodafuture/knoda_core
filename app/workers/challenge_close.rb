class ChallengeClose
  include Sidekiq::Worker

  def perform(challenge_id)
    ActiveRecord::Base.connection_pool.with_connection do
      Challenge.find(challenge_id).close_async
    end
  end
end
