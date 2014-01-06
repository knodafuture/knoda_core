class Comment < ActiveRecord::Base
  belongs_to :user, inverse_of: :comments
  belongs_to :prediction, inverse_of: :comments

  validates :user_id, presence: true
  validates :prediction_id, presence: true

  after_commit :create_activities
  
  include Authority::Abilities
  self.authorizer_name = 'CommentAuthorizer'

  scope :recent, lambda {{ :order => "comments.created_at DESC" } }
  scope :id_lt, -> (i) {where('comments.id < ?', i) if i}

  def create_activities
    commentingUsers = self.prediction.comments.group_by { |c| c.user_id}
    if self.prediction.user.id != self.user_id
      a = Activity.find_or_initialize_by(user_id: self.prediction.user.id, prediction_id: self.prediction.id, activity_type: 'COMMENT')
      a.title = (commentingUsers.length == 1) ? "#{commentingUsers.length} person commented on" : "#{commentingUsers.length} people commented on"
      a.prediction_body = self.prediction.body
      a.created_at = DateTime.now
      a.seen = false
      a.save
    end
    Comment.select('user_id').where("prediction_id = ?", self.prediction.id).group("user_id").each do |c|
      if c.user_id != self.user_id
        a = Activity.find_or_initialize_by(user_id: c.user_id, prediction_id: self.prediction.id, activity_type: 'COMMENT')
        a.title = (commentingUsers.length == 1) ? "#{commentingUsers.length} person commented on" : "#{commentingUsers.length} people commented on"        
        a.prediction_body = self.prediction.body
        a.created_at = DateTime.now
        a.seen = false
        a.save      
      end
    end
  end
end
