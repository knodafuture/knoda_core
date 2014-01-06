class Activity < ActiveRecord::Base
  belongs_to :user

  validates :user_id, presence: true
  validates :prediction_id, presence: true
  validates :title, presence: true
  validates :prediction_body, presence: true
  validates :activity_type, presence: true
  
  include Authority::Abilities
  self.authorizer_name = 'ActivityAuthorizer'

  scope :latest, -> { order('created_at DESC') }
  scope :id_lt, -> (i) {where('activities.id < ?', i) if i}
  scope :unseen, -> {where('seen is false')}
end
