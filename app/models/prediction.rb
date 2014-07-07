require 'owly'
require 'render_anywhere'
require 'imgkit'
class Prediction < ActiveRecord::Base
  searchkick
  include RenderAnywhere
  include Authority::Abilities
  include PredictionImageBuilder
  include ActionView::Helpers::DateHelper
  self.authorizer_name = 'PredictionAuthorizer'

  after_create :create_own_challenge
  after_create :shortenUrl
  after_create :after_create

  belongs_to :user, inverse_of: :predictions
  belongs_to :group, inverse_of: :predictions

  has_many :challenges, inverse_of: :prediction, :dependent => :destroy
  has_many :voters, through: :challenges, class_name: "User", source: 'user'
  has_many :comments, -> { order('created_at ASC') }, inverse_of: :prediction, :dependent => :destroy

  validates :body, presence: true
  validates :expires_at, presence: true

  validates :tags, presence: true
  validate  :max_tag_count
  validate  :expires_at_is_not_past, :on => :create
  validate  :new_expires_at_is_not_past, :on => :update
  validate  :resolution_is_not_past, :on => :update

  validates_length_of :body, :maximum => 300

  attr_accessor :in_bs

  scope :recent, -> {where("predictions.expires_at >= now()")}
  scope :expiring, -> { where("predictions.expires_at >= now()").order("predictions.expires_at ASC") }

  scope :latest, -> { order('created_at DESC') }

  scope :id_lt, -> (i) {where('predictions.id < ?', i) if i}

  scope :unnotified, -> {where('push_notified_at is null')}
  scope :expired, -> {where('is_closed is false and resolution_date is not null and resolution_date < now()')}
  scope :readyForResolution, -> {where('is_closed is false and resolution_date < now()')}
  scope :notAlerted, -> {where('activity_sent_at is null')}
  scope :for_group, -> (i) {where('group_id = ?', i) if i}
  scope :losers, -> {where(:is_right => false)}
  scope :winners, -> {where(:is_right => false)}
  scope :visible_to_user, -> (i) {
    if i
      where('group_id is null or group_id in (Select group_id from memberships where user_id = ?)', i)
    else
      where('group_id is null')
    end
  }

  def disagreed_count
    d = self.challenges.select { |c| c.agree == false}
    d.length
  end

  def agreed_count
    a = self.challenges.select { |c| c.agree == true}
    a.length
  end

  def loser_count
    a = self.challenges.select { |c| c.is_right == false }
    a.length
  end

  def winner_count
    a = self.challenges.select { |c| c.is_right == true }
    a.length
  end

  def called_out_loser
    losingChallenge = (self.challenges.where("is_right is false").order("is_own DESC, id DESC").first)
    if losingChallenge
      return losingChallenge.user
    else
      return nil
    end
  end

  def called_out_winner
    winningChallenge = (self.challenges.where("is_right is true").order("is_own DESC, id DESC").first)
    if winningChallenge
      return winningChallenge.user
    else
      return nil
    end
  end

  def agree_percentage
    (self.agreed_count.fdiv(self.challenges.length) * 100.0).round(0)
  end

  def comment_count
    self.comments.length
  end

  def market_size
    self.challenges.length
  end

  def prediction_market
    if self.outcome == true
      return (self.agreed_count.fdiv(self.market_size) * 100.0).round(2)
    else
      return (self.disagreed_count.fdiv(self.market_size) * 100.0).round(2)
    end
  end

  def market_size_points
    case self.market_size
      when 0..5
        0
      when 6..20
        10
      when 21..100
        20
      when 101..500
        30
      when 501..(1.0/0.0)
        40
    end
  end

  def prediction_market_points
    case self.prediction_market
      when 0.0..15.00
        50
      when 15.00..30.00
        40
      when 30.00..50.00
        30
      when 50.00..75.00
        20
      when 75.00..95.00
        10
      when 95.00..100.00
        0
    end
  end

  def close_as(outcome)
    if self.update({outcome: outcome, is_closed: true, closed_at: Time.now})
      self.challenges.each do |c|
        c.close
      end
      true
    else
      false
    end
  end

  def revert
    self.in_bs = true
    self.challenges.each do |c|
      c.user.update({points: c.user.points - c.total_points})
      c.update({is_right: false, is_finished: false, bs: false})
    end

    self.close_as(!self.outcome)
  end

  def request_for_bs
    bs_count = self.challenges.where(bs: true).count
    if bs_count.fdiv(self.challenges.count-1) >= 0.25
      self.revert
      true
    else
      false
    end
  end

  def is_expired?
    self.expires_at.past?
  end

  def settled
    is_closed?
  end

  def expired
    expires_at && expires_at.past?
  end

  def is_ready_for_resolution?
    resolution_date.past?
  end

  def after_close
    if self.errors.size == 0
      Activity.where(user_id: self.user.id, prediction_id: self.id, activity_type: 'EXPIRED').delete_all
      if self.group
        Group.rebuildLeaderboards(self.group)
      end
    end
  end

  def after_create
    PredictionImageWorker.perform_async(self.id)
  end

  def search_data
    {
        body: body,
        tags: tags,
        challenge_count: Math.log(challenges.size,2)
    }
  end

  def predicted_text
    t = distance_text(self.created_at)
    return "made #{t} ago"
  end

  def expired_text
    t = distance_text(self.expires_at)
    if self.expires_at > Time.now
      return "closes #{t}"
    else
      return "closed #{t} ago"
    end
  end

  def distance_text(d)
    t = distance_of_time_in_words_to_now(d)
    t.gsub!("about ", '')
    t.gsub!("less than a",'1')
    t.gsub!("almost ",'')
    t.gsub!("over ",'')
    t.gsub!(" years", 'yrs')
    t.gsub!(" year", 'yr')
    t.gsub!(" months", 'mo')
    t.gsub!(" month", 'mo')
    t.gsub!(" days", 'd')
    t.gsub!(" day", 'd')
    t.gsub!(" hours", 'h')
    t.gsub!(" hour", 'h')
    t.gsub!(" minutes", 'm')
    t.gsub!(" minute", 'm')
    t.gsub!(" seconds", 's')
    t.gsub!(" second", 's')
    return t
  end

  private

  def is_not_settled
    errors[:expires_at] << "prediction is settled" if self.is_closed?
  end

  def expires_at_is_not_past
    return unless self.expires_at
    errors[:expires_at] << "is past" if self.expires_at.past?
  end

  def new_expires_at_is_not_past
    if self.expires_at_changed?
      errors[:expires_at] << "is past" if self.expires_at.past?
    end
  end

  def resolution_is_not_past
    if self.resolution_date_changed?
      errors[:resolution_date] << "is past" if self.resolution_date < self.expires_at
      errors[:resolution_date] << "is past" if self.resolution_date.past?
    end
  end

  def max_tag_count
    errors[:tags] << "1 tag maximum" if self.tags.size > 1
  end

  def tag_existence
    self.tags.each do |tag_name|
      if Topic.where(name: tag_name, hidden: false).first.nil?
        errors[:tags] << "invalid tag #{tag_name}"
      end
    end
  end

  def create_own_challenge
    self.challenges.create!(user: self.user, agree: true, is_own: true)
  end

  def shortenUrl
    long_url = "#{Rails.application.config.knoda_web_url}/predictions/#{self.id}/share"
    if Rails.env.production?
      begin
        self.short_url = Owly::Shortener.shorten("CPdDACuu4AeEdMK2RyIDR", long_url, {:base_url => "http://knoda.co"})
      rescue
        self.short_url = long_url
      end
    else
      self.short_url = long_url
    end
    self.save()
  end


end
