class GroupAuthorizer < ApplicationAuthorizer
  def self.readable_by?(user)
    true
  end

  def updatable_by?(user)
    return Membership.where(:user => user, :group => resource, :role => 'OWNER').size > 0
  end  
end