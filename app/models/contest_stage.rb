class ContestStage < ActiveRecord::Base
  #include Authority::Abilities
  #self.authorizer_name = 'ContestAuthorizer'

  has_many :predictions
  belongs_to :contest, inverse_of: :contest_stages

  validates_presence_of   :name
  validates_length_of :name, maximum: 30
end
