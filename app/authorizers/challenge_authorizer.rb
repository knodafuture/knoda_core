class ChallengeAuthorizer < ApplicationAuthorizer

  def self.creatable_by?(user)
  	true
  end

  def self.readable_by?(user)
    true
  end
  
  def self.set_seenable_by?(user)
    true
  end
end