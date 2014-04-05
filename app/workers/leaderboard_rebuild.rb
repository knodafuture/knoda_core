class LeaderboardRebuild
  include SuckerPunch::Job
  @queue = :leaderboard_rebuild

  def perform(group_id)
    ActiveRecord::Base.connection_pool.with_connection do
      Group.rebuildLeaderboards(Group.find(group_id))
    end
  end
end