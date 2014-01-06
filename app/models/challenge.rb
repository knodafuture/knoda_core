class Challenge < ActiveRecord::Base
  belongs_to :user, inverse_of: :challenges
  belongs_to :prediction, inverse_of: :challenges

  validates :user_id, presence: true
  validates :prediction_id, presence: true

  validates_uniqueness_of :prediction_id, :scope => :user_id
  validate :prediction_is_not_expired, :on => :create
  validate :prediction_is_not_closed, :on => :create
  
  after_create :challenge_create_badges
  
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
    if self.is_own
      title = (self.agree == self.prediction.outcome) ? "You won #{self.total_points} points for" : "You lost but still got #{self.total_points} points for your prediction"
    else
      title = (self.agree == self.prediction.outcome) ? "Your vote was right and you earned #{self.total_points} points" : "Your vote was wrong but you earned #{self.total_points} points"
    end
    activity_type = (self.agree == self.prediction.outcome) ? 'WON' : 'LOST'
    Activity.create!(user: self.user, prediction_id: self.prediction.id, title: title, prediction_body: self.prediction.body, activity_type: activity_type);
  end
  
  def points_details
    {
      base_points: self.base_points,
      outcome_points: self.outcome_points,
      market_size_points: self.market_size_points,
      prediction_market_points: self.prediction_market_points
    }
  end

  private

  def prediction_is_not_expired
    errors[:prediction] << "prediction is expired" if self.prediction.expires_at.past?
  end

  def prediction_is_not_closed
    errors[:prediction] << "prediction is closed" if !self.prediction.closed_at.nil?
  end
  
  def challenge_create_badges
    if not self.is_own
      self.user.challenge_create_badges
    end
  end
end
