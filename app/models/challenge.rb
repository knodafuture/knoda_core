class Challenge < ActiveRecord::Base
  belongs_to :user, inverse_of: :challenges
  belongs_to :prediction, inverse_of: :challenges

  validates :user_id, presence: true
  validates :prediction_id, presence: true

  validates_uniqueness_of :prediction_id, :scope => :user_id
  validate :prediction_is_not_expired, :on => :create
  validate :prediction_is_not_closed, :on => :create

  scope :ownedAndPicked, -> {includes(:prediction, :user).order('created_at DESC')}
  scope :own, -> {joins(:prediction).where(is_own: true).order('created_at DESC')}
  scope :picks, -> {joins(:prediction).where(is_own: false).order('created_at DESC')}
  scope :completed, -> {joins(:prediction).where(is_own: false, is_finished: true).order('expires_at DESC')}

  scope :won_picks, -> {joins(:prediction).where(is_own: false, is_finished: true, is_right: true).order('expires_at DESC')}
  scope :lost_picks, -> {joins(:prediction).where(is_own: false, is_finished: true, is_right: false).order('expires_at DESC')}
  scope :unviewed, -> {where(seen: false)}
  scope :expired, -> {joins(:prediction).where("is_own is true and is_closed is false and ((resolution_date is null and expires_at < ?) or (resolution_date is not null and resolution_date < ?))", Time.now, Time.now).order("expires_at DESC")}

  scope :agreed_by_users, ->{where(agree: true).order('created_at DESC')}
  scope :disagreed_by_users, ->{where(agree: false).order('created_at DESC')}

  scope :notifications, -> {joins(:prediction).
    where("((is_own IS FALSE) and (is_finished IS TRUE)) or ((is_own IS TRUE) and (resolution_date < now()))").
    order("CASE WHEN is_finished IS TRUE THEN predictions.closed_at ELSE predictions.expires_at END DESC")
  }

  scope :last_day, ->{where("created_at >= ?", DateTime.now - 24.hours)}

  scope :created_at_lt, -> (i) {where('challenges.created_at < ?', i) if i}
  scope :id_lt, -> (i) {where('challenges.prediction_id < ?', i) if i}

  # Adds `creatable_by?(user)`, etc
  include Authority::Abilities
  self.authorizer_name = 'ChallengeAuthorizer'

  after_create :update_leaderboards


  def update_leaderboards
    if self.prediction.contest
      ContestLeaderboardRebuild.perform_async(self.prediction.contest_id, self.prediction.contest_stage_id)
    end
  end

  def base_points
    if self.is_own
      10 # inceptive for user making the prediction
    else
      5 # inceptive for user agreeing or disagreeing with prediction
    end
  end

  def outcome_points
    if self.agree == self.prediction.outcome
      10
    else
      0
    end
  end

  def market_size_points
    if self.is_own
      self.prediction.market_size_points
    else
      0
    end
  end

  def prediction_market_points
    if self.agree == self.prediction.outcome and self.is_own
      self.prediction.prediction_market_points
    else
      0
    end
  end

  def total_points
    p = self.base_points + self.outcome_points + self.prediction_market_points
    if self.is_own
      p += self.market_size_points
    end
    return p
  end

  def close
    self.update({is_right: (self.agree == self.prediction.outcome), is_finished: true})
    self.user.update({points: self.user.points + self.total_points})
    self.user.update_streak(self.is_right)
    self.user.save!
    ChallengeClose.perform_in(5.seconds, self.id)
    FindRivals.perform_in(5.seconds, self.user_id)
  end

  def close_async
    Activity.create!(self.to_activity)
    if self.user.notification_settings.where(:setting => 'PUSH_OUTCOME').first.active == true and not self.is_own
      OutcomePushNotifier.deliver(self)
    end
  end

  def points_details
    {
      base_points: self.base_points,
      outcome_points: self.outcome_points,
      market_size_points: self.market_size_points,
      prediction_market_points: self.prediction_market_points
    }
  end

  def to_activity
    activity_type = (self.agree == self.prediction.outcome) ? 'WON' : 'LOST'
    shareable = (self.prediction.group == nil)
    return {:user => self.user, :prediction_id => self.prediction.id, :title => notification_title(), :prediction_body => self.prediction.body, :activity_type => activity_type, :image_url => notification_image_url(), :shareable => shareable}
  end

  def push_outcome_text
    text = notification_title()
    prediction_text_sub = self.prediction.body.slice(0,100)
    text << " \"#{prediction_text_sub}\""
    return text
  end


  def notification_title
    title = ""
    if self.is_right
      title = "You Won - Booya!"
      if self.prediction and self.prediction.called_out_loser
        lc = (self.prediction.loser_count - 1)
        if lc == 0
          title << " You beat #{self.prediction.called_out_loser.username}."
        elsif lc == 1
          title << " You beat #{self.prediction.called_out_loser.username} & #{lc} other user."
        else
          title << " You beat #{self.prediction.called_out_loser.username} & #{lc} others."
        end
      end
    else
      title = "You Lost - Bummer."
      if self.prediction and self.prediction.called_out_winner
        wc = (self.prediction.winner_count - 1)
        if wc == 0
          title << " #{self.prediction.called_out_winner.username} beat you."
        elsif wc == 1
          title << " #{self.prediction.called_out_winner.username} & #{wc} other user beat you."
        else
          title << " #{self.prediction.called_out_winner.username} & #{wc} others beat you."
        end
      end
    end
    return title
  end

  def notification_image_url
    if self.is_right
      if self.prediction and self.prediction.called_out_loser and self.prediction.called_out_loser.avatar_image
        return self.prediction.called_out_loser.avatar_image[:small]
      else
        if self.user.avatar_image
          return self.user.avatar_image[:small]
        end
      end
    else
      if self.prediction and self.prediction.called_out_winner and self.prediction.called_out_winner.avatar_image
        return self.prediction.called_out_winner.avatar_image[:small]
      else
        if self.user.avatar_image
          return self.user.avatar_image[:small]
        end
      end
    end
  end


  private

  def prediction_is_not_expired
    errors[:prediction] << "prediction is expired" if self.prediction.expires_at.past?
  end

  def prediction_is_not_closed
    errors[:prediction] << "prediction is closed" if !self.prediction.closed_at.nil?
  end
end
