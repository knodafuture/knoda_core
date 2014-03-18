class GroupAuthorizer < ApplicationAuthorizer
  def readable_by?(user)
    return Membership.where(:user => user, :group => resource).size > 0
  end

  def updatable_by?(user)
    return Membership.where(:user => user, :group => resource, :role => 'OWNER').size > 0
  end  
end