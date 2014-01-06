class Badge < ActiveRecord::Base
  belongs_to :user
  
  scope :unseen, -> {where(seen: false)}
  
  include Authority::Abilities
  self.authorizer_name = 'BadgeAuthorizer'
end
