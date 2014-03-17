class MembershipAuthorizer < ApplicationAuthorizer
  def self.creatable_by?(user)
    true
  end
  
  def self.readable_by?(user)
    true
  end

  def deletable_by?(user)
    puts 'AUTHORIZER'
    return Membership.where(:user => user, :group => resource.group, :role => 'OWNER').size > 0
  end
end