class ContestAuthorizer < ApplicationAuthorizer
  def readable_by?(user)
    return true
  end

  def updatable_by?(user)
    user.id == resource.user_id
  end

  def deletable_by?(user)
    user.id == resource.user_id
  end
end
