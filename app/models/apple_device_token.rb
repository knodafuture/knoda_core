class AppleDeviceToken < ActiveRecord::Base
  belongs_to :user
  validates :token, presence: true
  
  include Authority::Abilities
  self.authorizer_name = 'AppleDeviceTokenAuthorizer'
end
