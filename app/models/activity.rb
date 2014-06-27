class Activity < ActiveRecord::Base
  belongs_to :user

  validates :user_id, presence: true
  validates :activity_type, presence: true

  validate :prediction_or_invitation

  include Authority::Abilities
  self.authorizer_name = 'ActivityAuthorizer'

  scope :latest, -> { order('created_at DESC') }
  scope :id_lt, -> (i) {where('activities.id < ?', i) if i}
  scope :unseen, -> {where('seen is false')}

  private
    def prediction_or_invitation
      if activity_type == 'INVITATION'
        if (invitation_code.blank? || invitation_sender.blank? || invitation_group_name.blank?)
          errors.add(:base, "Specify an invitation code, sender, and group_name")
        end
      else
        if (prediction_id.blank? || prediction_body.blank?)
          errors.add(:base, "Specify an prediction_id and body")
        end
      end
    end
end
