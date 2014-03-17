class Group < ActiveRecord::Base
  include Authority::Abilities
  include CroppableAvatar
  self.authorizer_name = 'GroupAuthorizer'

  has_many :predictions
  has_many :memberships
  has_many :users, through: :memberships
  has_attached_file :avatar, :styles => { :big => "344х344>", :small => "100x100>"}

  validates_presence_of   :name

  def avatar_image
    if self.avatar.exists?
      {
        big: self.avatar(:big),
        small: self.avatar(:small),
        thumb: self.avatar(:thumb)
      }
    else
      {
        big: "http://placehold.it/344x344",
        small: "http://placehold.it/100x100"
      }
    end
  end

  def owned_by?(user)
    return self.memberships.where(:user => user, :role => 'OWNER').size > 0
  end     

  def self.weeklyLeaderboard(group)
    leaderboard(group, 8.days.ago)
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
      users = users.sort!{|u1,u2| u2.group_won(group.id, 8.days.ago) <=> u1.group_won(group.id, max_age)}
      leaders = []
      i = 0
      users.each do |u|
        i = i + 1
        leaders << {:rank => i, :rankText => "#{i.ordinalize} of #{users.size}", :user_id => u.id, :username => u.username, :avatar_image => u.avatar_image, :won => u.group_won(group.id, 8.days.ago), :lost => u.group_lost(group.id, 8.days.ago), :verified_account => u.verified_account}
      end
      return leaders      
    end
end
