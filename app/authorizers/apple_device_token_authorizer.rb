class AppleDeviceTokenAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    true
  end
  
  def self.readable_by?(user)
    true
  end

  def deletable_by?(user)
  	user.id == resource.user_id
  end
end