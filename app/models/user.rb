require 'searchkick'
class User < ActiveRecord::Base
  searchkick text_start: [:username]
  include Authority::UserAbilities
  include CroppableAvatar
  include Authority::Abilities
  self.authorizer_name = 'UserAuthorizer'

  after_create :update_notification_settings
  after_create :registration_badges
  after_create :send_signup_email

  before_update :send_email_if_username_was_changed
  before_update :send_email_if_email_was_changed

  has_many :predictions, inverse_of: :user, :dependent => :destroy
  has_many :challenges, inverse_of: :user, :dependent => :destroy
  has_many :badges, :dependent => :destroy
  has_many :voted_predictions, through: :challenges, class_name: "Prediction", source: 'prediction'
  has_many :apple_device_tokens, :dependent => :destroy
  has_many :android_device_tokens, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :activities, :dependent => :destroy
  has_many :memberships
  has_many :groups, through: :memberships
  has_many :invitations
  has_many :referrals
  has_many :social_accounts
  has_many :user_events
  has_many :notification_settings

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :omniauthable,
         :authentication_keys => [:login]

  validates_presence_of   :username
  validates_uniqueness_of :username, :case_sensitive => false
  validates_format_of     :username, :with => /\A[a-zA-Z0-9_]{1,15}\z/

  attr_accessor :login

  def self.username_length
    return 15
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def won
    r = self.challenges.select { |c| c.is_finished == true and c.is_right == true}
    r.length
  end

  def lost
    r = self.challenges.select { |c| c.is_finished == true and c.is_right == false}
    r.length
  end

  def winning_percentage
    if self.won > 0
      (self.won.to_f / (self.won + self.lost) * 100.0).round(2)
    else
      0.00
    end
  end

  def update_streak(won)
    if won
      self.streak = (self.streak > 0) ? self.streak+1 : +1
    else
      self.streak = (self.streak < 0) ? self.streak-1 : -1
    end
  end

  def registration_badges
    case self.id
      when 1..500
        self.badges.create(:name => 'gold_founding')
      when 501..5000
        self.badges.create(:name => 'silver_founding')
    end
  end

  def prediction_create_badges
    case self.predictions.size
      when 1
        self.badges.create(:name => '1_prediction')
      when 10
        self.badges.create(:name => '10_predictions')
    end
  end

  def challenge_create_badges
    case self.challenges.where(is_own: false).count
      when 1
        self.badges.create(:name => '1_challenge')
    end
  end

  def outcome_badges
    # 10 correct predictions badge
    correct_predictions = self.predictions.where(outcome: true).count
    correct_badge = self.badges.where(name: '10_correct_predictions').first

    if correct_badge
      if correct_predictions < 10
        correct_badge.delete
      end
    else
      if correct_predictions > 9
        self.badges.create(name: '10_correct_predictions')
      end
    end

    # 10 incorrect predictions badge
    incorrect_predictions = self.predictions.where(outcome: false).count
    incorrect_badge = self.badges.where(name: '10_incorrect_predictions').first
    if incorrect_badge
      if incorrect_predictions < 10
        incorrect_badge.delete
      end
    else
      if incorrect_predictions > 9
        self.badges.create(name: '10_incorrect_predictions')
      end
    end
  end

  def pick(prediction, agree)
    self.challenges.build({
      prediction: prediction,
      agree: agree
    })
  end

  def alerts_count
    self.activities.unseen.count
  end


  def update_notification_settings
    self.notification_settings.create!(:user => self, :setting => 'PUSH_EXPIRED', :display_name => 'Expired Predictions', :description => 'Notify me when I need to settle a prediction I made.', :active => true)
    self.notification_settings.create!(:user => self, :setting => 'PUSH_GROUP_INVITATION',  :display_name => 'Group Invitations', :description => 'Notify me when I am invited to join a group.',:active => true)
    self.notification_settings.create!(:user => self, :setting => 'PUSH_COMMENTS', :display_name => 'Comments', :description => 'Notify me when other users comment on my predictions, or reply to my comments.',:active => true)
    self.notification_settings.create!(:user => self, :setting => 'PUSH_OUTCOME',  :display_name => 'Wins & Losses', :description => 'Notify me when I win or lose a prediction I voted on.',:active => false)
  end

  def send_signup_email
    if self.email != nil
      UserWelcomeEmail.perform_async(self.id)
    end
  end

  def send_email_if_username_was_changed
    if self.username_changed? and self.email != nil and self.username_was != "Guest#{self.id}"
      UserMailer.username_was_changed(self).deliver
    end
  end

  def send_email_if_email_was_changed
    if self.email_changed? and self.email_was != nil
      UserMailer.email_was_changed(self).deliver
    end
  end

  def search_data
    {
      username: username,
      points: points
    }
  end

  def streak_as_text
    if self.streak == 0
      return "W#{0}"
    end

    if self.streak > 0
      return "W#{self.streak}"
    end

    if self.streak < 0
      return "L#{self.streak.abs}"
    end
  end

  def to_param
    username
  end

  def remember_me
    true
  end

  def group_won(group_id, max_time)
    r = self.challenges.includes(:prediction).select { |c| c.prediction.group_id == group_id and c.is_finished == true and c.is_right == true and c.prediction.closed_at > max_time}
    r.length
  end

  def group_lost(group_id, max_time)
    r = self.challenges.includes(:prediction).select { |c| c.prediction.group_id == group_id and c.is_finished == true and c.is_right == false and c.prediction.closed_at > max_time}
    r.length
  end

  def member_of(group)
    return self.memberships.where(:group_id => group.id).size > 0
  end

  def email_required?
    !self.social_accounts
  end

  def twitter_account
    return social_accounts.where(:provider_name => "twitter").first
  end

  def facebook_account
    return social_accounts.where(:provider_name => "facebook").first
  end


  def self.sanitize_new_username(username)
    users = User.where("username ilike ?", username + "%")
    if username.length < User.username_length and users.size < 1
      return username
    end

    if username.length > User.username_length
      username = username[0..User.username_length-2]
      return sanitize_new_username(username)
    end
    if users.size > 0
        username = username += users.size.to_s
        return sanitize_new_username(username)
    end
    return username
  end

  def self.find_or_create_from_social(social_params)
    account = SocialAccount.where(:provider_name => social_params[:provider_name], :provider_id => social_params[:provider_id]).first
    if account and account.user
      account.access_token = social_params[:access_token]
      account.access_token_secret = social_params[:access_token_secret]
      account.save()
      return account.user
    end
    if social_params[:current_user]
      user = social_params[:current_user]
    else
      user = User.new
    end
    user.username = sanitize_new_username(social_params[:username])
    if social_params[:email]
      user.email = social_params[:email]
    else
      user.email = nil
    end
    user.password = Devise.friendly_token[0,6]
    user.avatar = user.avatar_from_url social_params[:image]
    user.save
    if social_params[:current_user]
      UserEvent.new(:user_id => user.id, :name => 'SIGNUP', :platform => social_params[:signup_source]).save
    else
      UserEvent.new(:user_id => user.id, :name => 'CONVERT', :platform => social_params[:signup_source]).save
    end
    unless user.errors.empty?
      return user
    end
    account = SocialAccount.new
    account.provider_name = social_params[:provider_name]
    account.provider_id = social_params[:provider_id]
    account.access_token = social_params[:access_token]
    account.access_token_secret = social_params[:access_token_secret]
    account.provider_account_name = social_params[:provider_account_name]
    account.user = user
    account.save!
    return user
  end
end
