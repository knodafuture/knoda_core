class Membership < ActiveRecord::Base
  include Authority::Abilities
  self.authorizer_name = 'MembershipAuthorizer'  
  belongs_to :user
  belongs_to :group

  def username
    return self.user.username
  end
end
