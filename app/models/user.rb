require 'searchkick'
class User < ActiveRecord::Base
  searchkick text_start: [:username]
  include Authority::UserAbilities
  include CroppableAvatar
  include Authority::Abilities
  self.authorizer_name = 'UserAuthorizer'

  after_create :update_notification_settings
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
  has_many :contests, :inverse_of => :user


  has_many :followings
  has_many :leaders, :through => :followings
  has_many :inverse_followings, :class_name => "Following", :foreign_key => "leader_id"
  has_many :followers, :through => :inverse_followings, :source => :user

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :omniauthable,
         :authentication_keys => [:login],
         :remember_for => 2.years

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

  def reprocess_streak
    c = self.challenges.joins(:prediction).where(:is_finished => true).order('predictions.closed_at desc')
    s = 0
    direction = nil
    c.each do |i|
      puts 'processing one: is_right = ' + i.is_right.to_s
      if i.is_right
        break if (direction and direction != 'W')
        direction = 'W'
        s = s+ 1
      else
        break if (direction and direction != 'L')
        direction = 'L'
        s = s - 1
      end
    end
    self.streak = s
    self.save
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

  def is_admin?
    roles.include?('ADMIN')
  end

  def is_editor?
    roles.include?('CONTEST_EDITOR')
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
      user.guest_mode = false
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
      UserEvent.new(:user_id => user.id, :name => 'CONVERT', :platform => social_params[:signup_source]).save
    else
      UserEvent.new(:user_id => user.id, :name => 'SIGNUP', :platform => social_params[:signup_source]).save
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

  def facebook_friends_on_knoda
    if facebook_account and facebook_account.access_token
      graph = Koala::Facebook::API.new(facebook_account.access_token)
      friends = graph.get_connections("me", "friends")
      ids = friends.collect { |x| x['id'] }
      sa = SocialAccount.includes(:user).where(:provider_name => 'facebook', :provider_id => ids)
      output = []
      sa.each do |s|
        contact_id = friends.select { |f| f['id'] == s.provider_id}[0]['name']
        output << { :contact_id => contact_id, :knoda_info => {:user_id => s.user.id, :username => s.user.username}}
      end
      return output
    else
      return nil
    end
  end

  def twitter_friends_on_knoda
    if twitter_account and twitter_account.access_token
      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.config.twitter_key
        config.consumer_secret     = Rails.application.config.twitter_secret
        config.access_token        = twitter_account.access_token
        config.access_token_secret = twitter_account.access_token_secret
      end
      friends = client.friends.to_a
      ids = friends.collect { |x| x.id.to_s }
      sa = SocialAccount.includes(:user).where(:provider_name => 'twitter', :provider_id => ids)
      output = []
      sa.each do |s|
        contact_id = friends.select { |f| f.id.to_s == s.provider_id}[0].name
        output << { :contact_id => contact_id, :knoda_info => {:user_id => s.user.id, :username => s.user.username}}
      end
      return output
    else
      return nil
    end
  end

  def followed_by?(user)
    return self.followers.select { |x| x.id == user.id}.size > 0
  end

  def led_by?(user)
    return self.leaders.select { |x| x.id == user.id}.size > 0
  end

  def following(user)
    return self.inverse_followings.select { |x| x.user_id == user.id}[0]
  end
end
