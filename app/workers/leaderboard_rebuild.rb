class LeaderboardRebuild
  #include SuckerPunch::Job
  include Sidekiq::Worker
  @queue = :leaderboard_rebuild

  def perform(group_id)
    puts "PERFORM LEADERBOARD REBUILD"
    ActiveRecord::Base.connection_pool.with_connection do
      Group.rebuildLeaderboards(Group.find(group_id))
    end
  end
end
