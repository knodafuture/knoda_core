class LeaderboardRebuild
  include Sidekiq::Worker

  def perform(group_id)
    puts "PERFORM LEADERBOARD REBUILD"
    ActiveRecord::Base.connection_pool.with_connection do
      Group.rebuildLeaderboards(Group.find(group_id))
    end
  end
end
