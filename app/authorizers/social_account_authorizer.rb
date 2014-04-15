class SocialAccountAuthorizer < ApplicationAuthorizer
  def updatable_by?(user)
    return resource.user_id == user.id
  end

  def deletable_by?(user)
  	return resource.user_id == user.id
  end

  def self.readable_by?(user)
    return true
  end
end