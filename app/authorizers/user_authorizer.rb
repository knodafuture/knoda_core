class UserAuthorizer < ApplicationAuthorizer
  def updatable_by?(user)
    return resource.id == user.id
  end

  def self.readable_by?(user)
    return true
  end
end
