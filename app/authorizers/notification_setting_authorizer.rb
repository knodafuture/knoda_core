class NotificationSettingAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    false
  end

  def self.readable_by?(user)
    true
  end

  def updatable_by?(user)
    return resource.user == user
  end
end
