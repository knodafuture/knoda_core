class Topic < ActiveRecord::Base
  scope :find_active, -> { where('hidden is false')}
  
  include Authority::Abilities
  self.authorizer_name = 'TopicAuthorizer'
end
