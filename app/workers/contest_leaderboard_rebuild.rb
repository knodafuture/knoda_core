class ContestLeaderboardRebuild
  include Sidekiq::Worker

  def perform(contest_id, contest_stage_id=nil)
    ActiveRecord::Base.connection_pool.with_connection do
      if contest_stage_id
        Contest.rebuildLeaderboards(Contest.find(contest_id), ContestStage.find(contest_stage_id))
      else
        Contest.rebuildLeaderboards(Contest.find(contest_id))
      end
    end
  end
end
