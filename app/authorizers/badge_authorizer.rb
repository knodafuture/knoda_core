class BadgeAuthorizer < ApplicationAuthorizer
  def self.readable_by?(user)
    true
  end
  
  def self.recentable_by?(user)
    true
  end
end