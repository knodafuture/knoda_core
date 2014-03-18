class MembershipAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    true
  end
  
  def self.readable_by?(user)
    true
  end

  def deletable_by?(user)
    isOwner =  Membership.where(:user => user, :group => resource.group, :role => 'OWNER').size > 0
    isDeletingSelf = Membership.where(:user => user, :id => resource.id, :role => 'MEMBER').size > 0
    return (isOwner or isDeletingSelf)
  end
end