class Topic < ActiveRecord::Base
  scope :find_active, -> { where('hidden is false') }
  scope :sorted, -> { order('sort_order ASC') }
  
  include Authority::Abilities
  self.authorizer_name = 'TopicAuthorizer'
end
