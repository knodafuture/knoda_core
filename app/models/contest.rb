class Contest < ActiveRecord::Base
  include Authority::Abilities
  include CroppableAvatar
  self.authorizer_name = 'ContestAuthorizer'

  has_many :predictions
  has_many :contest_stages
  belongs_to :user, :inverse_of => :contests

  validates_presence_of   :name
  validates_length_of :name, maximum: 30
  validates_length_of :description, maximum: 300

  default_scope { order('id DESC') }
  scope :entered_by_user, -> (i) { where(:id => Prediction.select(:contest_id).distinct.joins(:challenges).where('challenges.user_id' => i).where('contest_id is not null')) if i }
  scope :not_entered_by_user, -> (i) { where.not(:id => Prediction.select(:contest_id).distinct.joins(:challenges).where('challenges.user_id' => i).where('contest_id is not null')) if i}

  def leader_info
    lb = Contest.leaderboard(self)
    if lb.size > 0
      l = lb[0]
      if l[:won] > 0
        return {:username => l[:username], :id => l[:user_id]}
      end
    end
  end

  def participants
    return Contest.leaderboard(self).length
  end

  def self.leaderboard(contest)
    if Rails.cache.exist?("contest_leaderboard_#{contest.id}")
      return Rails.cache.read("contest_leaderboard_#{contest.id}")
    else
      lb = build_contest_leaderboard(contest)
      Rails.cache.write("contest_leaderboard_#{contest.id}", lb)
      return lb
    end
  end

  def self.stage_leaderboard(contest_stage)
    if Rails.cache.exist?("contest_stage_leaderboard_#{contest_stage.id}")
      return Rails.cache.read("contest_stage_leaderboard_#{contest_stage.id}")
    else
      lb = build_stage_leaderboard(contest_stage)
      Rails.cache.write("contest_stage_leaderboard_#{contest_stage.id}", lb)
      return lb
    end
  end


  def self.rebuildLeaderboards(contest, contest_stage=nil)
    Rails.cache.write("contest_leaderboard_#{contest.id}", build_contest_leaderboard(contest))
    if contest_stage
      Rails.cache.write("contest_stage_leaderboard_#{contest_stage.id}", build_stage_leaderboard(contest_stage))
    end
  end

  private
    def self.build_contest_leaderboard(contest)
      users = User.find_by_sql(["select *, (select count(*) from challenges INNER JOIN predictions ON predictions.id = challenges.prediction_id INNER JOIN users u on challenges.user_id = u.id where predictions.contest_id = ? and u.id = users.id and predictions.is_closed = true and challenges.is_right = true) won_count, (select count(*) from challenges INNER JOIN predictions ON predictions.id = challenges.prediction_id INNER JOIN users u on challenges.user_id = u.id where predictions.contest_id = ? and u.id = users.id and predictions.is_closed = true and challenges.is_right = false) lost_count from users where id in (select challenges.user_id from challenges INNER JOIN predictions ON predictions.id = challenges.prediction_id where predictions.contest_id = ?) order by won_count DESC;", contest.id, contest.id, contest.id])
      leaders = []
      i = 0
      users.each do |u|
        i = i + 1
        leaders << {:rank => i, :rankText => "#{i.ordinalize} of #{users.size}", :user_id => u.id, :username => u.username, :avatar_image => u.avatar_image, :won => u[:won_count], :lost => u[:lost_count], :verified_account => u.verified_account}
      end
      return leaders
    end

    def self.build_stage_leaderboard(contest_stage)
      users = User.find_by_sql(["select *, (select count(*) from challenges INNER JOIN predictions ON predictions.id = challenges.prediction_id INNER JOIN users u on challenges.user_id = u.id where predictions.contest_stage_id = ? and u.id = users.id and predictions.is_closed = true and challenges.is_right = true) won_count, (select count(*) from challenges INNER JOIN predictions ON predictions.id = challenges.prediction_id INNER JOIN users u on challenges.user_id = u.id where predictions.contest_stage_id = ? and u.id = users.id and predictions.is_closed = true and challenges.is_right = false) lost_count from users where id in (select challenges.user_id from challenges INNER JOIN predictions ON predictions.id = challenges.prediction_id where predictions.contest_stage_id = ?) order by won_count DESC;", contest_stage.id, contest_stage.id, contest_stage.id])
      leaders = []
      i = 0
      users.each do |u|
        i = i + 1
        leaders << {:rank => i, :rankText => "#{i.ordinalize} of #{users.size}", :user_id => u.id, :username => u.username, :avatar_image => u.avatar_image, :won => u[:won_count], :lost => u[:lost_count], :verified_account => u.verified_account}
      end
      return leaders
    end

end
