class User < ActiveRecord::Base
  # Adds `can_create?(resource)`, etc
  searchkick
  include Authority::UserAbilities
  
  after_create :registration_badges
  after_create :send_signup_email
  
  before_update :send_email_if_username_was_changed
  before_update :send_email_if_email_was_changed
  
  has_many :predictions, inverse_of: :user, :dependent => :destroy
  has_many :challenges, inverse_of: :user, :dependent => :destroy
  has_many :badges, :dependent => :destroy
  has_many :voted_predictions, through: :challenges, class_name: "Prediction", source: 'prediction'
  has_many :apple_device_tokens, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_many :activities, :dependent => :destroy
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable,
         :authentication_keys => [:login]
         
  validates_presence_of   :username
  validates_uniqueness_of :username, :case_sensitive => false


  validates_format_of     :username, :with => /\A[a-zA-Z0-9_]{1,15}\z/
  
  has_attached_file :avatar, :styles => { :big => "344х344>", :small => "100x100>"}
  
  attr_accessor :login
  
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
  
  def avatar_image
    if self.avatar.exists?
      {
        big: self.avatar(:big),
        small: self.avatar(:small),
        thumb: self.avatar(:thumb)
      }
    else
      nil
    end
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
        # Gold founding user badge
        self.badges.create(:name => 'gold_founding')
      when 501..5000
        # Silver founding user badge
        self.badges.create(:name => 'silver_founding')
    end
  end
  
  def prediction_create_badges
    case self.predictions.size
      when 1
        # first prediction badge
        self.badges.create(:name => '1_prediction')
      when 10
        # 10 predictions made 
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
    #self.challenges.notifications.unviewed.count
  end
  
  def send_signup_email
    UserMailer.signup(self).deliver
  end
  
  def send_email_if_username_was_changed
    if self.username_changed?
      UserMailer.username_was_changed(self).deliver
    end
  end
  
  def send_email_if_email_was_changed
    if self.email_changed?
      UserMailer.email_was_changed(self).deliver
    end
  end

  def search_data
    {
      username: username,
      email: email
    }
  end  
end
