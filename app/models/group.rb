require 'digest/sha1'
class Group < ActiveRecord::Base
  include Authority::Abilities
  include CroppableAvatar
  self.authorizer_name = 'GroupAuthorizer'

  has_many :predictions
  has_many :memberships
  has_many :users, through: :memberships

  validates_presence_of   :name
  validates_length_of :name, maximum: 30
  validates_length_of :description, maximum: 140

  after_create :shortenUrl

  default_scope order('name ASC')
  scope :id_lt, -> (i) {where('groups.id < ?', i) if i}
  scope :alphabetical, -> {order('name ASC')}
  
  def shortenUrl
    hashedId = Digest::SHA1.new << self.id.to_s
    self.share_id = hashedId.to_s
    if Rails.env.production?
      bitly = Bitly.new('adamnengland','R_098b05120c29c43ad74c6b6a0e7fcf64')
      page_url = bitly.shorten("#{Rails.application.config.knoda_web_url}/groups/join?id=#{hashedId}")
      self.share_url = page_url.short_url
    else
      self.share_url = "#{Rails.application.config.knoda_web_url}/groups/join?id=#{hashedId}"
    end
    self.save()    
  end

  def owned_by?(user)
    return self.memberships.where(:user => user, :role => 'OWNER').size > 0
  end     

  def owner
    return self.memberships.where(:role => 'OWNER').first.user
  end

  def self.rebuildLeaderboards(group)
    lb = leaderboard(group, 8.days.ago)
    Rails.cache.write("group_leaderboard_weekly_#{group.id}", lb, timeToLive: 7.days)
  end    

  def self.weeklyLeaderboard(group)
    if Rails.cache.exist?("group_leaderboard_weekly_#{group.id}")
      return Rails.cache.read("group_leaderboard_weekly_#{group.id}")
    else
      lb = leaderboard(group, 8.days.ago)
      Rails.cache.write("group_leaderboard_weekly_#{group.id}", lb, timeToLive: 7.days)
      return lb
    end    
  end

  def self.monthlyLeaderboard(group)
    leaderboard(group, 1.month.ago)
  end 

  def self.allTimeLeaderboard(group)
    leaderboard(group, 5.years.ago)
  end   

  private
    def self.leaderboard(group, max_age)
      users = group.users
      users = users.sort!{|u1,u2| u2.group_won(group.id, max_age) <=> u1.group_won(group.id, max_age)}
      leaders = []
      i = 0
      users.each do |u|
        i = i + 1
        leaders << {:rank => i, :rankText => "#{i.ordinalize} of #{users.size}", :user_id => u.id, :username => u.username, :avatar_image => u.avatar_image, :won => u.group_won(group.id, max_age), :lost => u.group_lost(group.id, max_age), :verified_account => u.verified_account}
      end
      return leaders      
    end
end
