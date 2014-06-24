class Comment < ActiveRecord::Base
  belongs_to :user, inverse_of: :comments
  belongs_to :prediction, inverse_of: :comments

  validates :user_id, presence: true
  validates :prediction_id, presence: true

  after_create :create_activities

  include Authority::Abilities
  self.authorizer_name = 'CommentAuthorizer'

  scope :recent, -> { order("comments.created_at DESC") }
  scope :id_lt, -> (i) {where('comments.id < ?', i) if i}
  scope :id_gt, -> (i) {where('comments.id > ?', i) if i}

  def create_activities
    NotifyCommentFollowers.perform_async(self.id)
  end

  def notify_users
    out = ""
    commentingUsers = self.prediction.comments.group_by { |c| c.user_id}
    if self.prediction.user.id != self.user_id
      a = Activity.find_or_initialize_by(user_id: self.prediction.user.id, prediction_id: self.prediction.id, activity_type: 'COMMENT')
      a.title = notification_title()
      a.prediction_body = self.prediction.body
      a.comment_body = self.text
      a.created_at = DateTime.now
      a.seen = false
      a.save
      if self.prediction.user.notification_settings.where(:setting => 'PUSH_COMMENTS').first.active == true
        CommentPushNotifier.deliver(self, self.prediction.user, true)
      end
    end
    Comment.select('user_id').where("prediction_id = ?", self.prediction.id).group("user_id").each do |c|
      if c.user_id != self.user_id
        a = Activity.find_or_initialize_by(user_id: c.user_id, prediction_id: self.prediction.id, activity_type: 'COMMENT')
        a.title = notification_title()
        a.prediction_body = self.prediction.body
        a.comment_body = self.text
        a.created_at = DateTime.now
        a.seen = false
        a.save
        if c.user.notification_settings.where(:setting => 'PUSH_COMMENTS').first.active == true
          CommentPushNotifier.deliver(self, c.user, false)
        end
      end
    end
    return out
  end

  def challenge
    self.user.challenges.where(prediction_id: self.prediction_id).first
  end

  def settled
    self.is_closed?
  end

  def expired
    self.expires_at && self.expires_at.past?
  end

  def to_push_text(is_owner)
    if self.text.length > 100
      comment_text_sub = self.text.slice(0,97) + "..."
    else
      comment_text_sub = self.text.slice(0,100)
    end
    t = notification_title()
    t <<  "\"#{comment_text_sub}\""
    return t
  end

private
  def notification_title
    commentingUsers = self.prediction.comments.group_by { |c| c.user_id}
    t = "#{self.user.username} "
    if commentingUsers.length > 2
      t << "& #{commentingUsers.length - 1} others "
    elsif commentingUsers.length == 2
      t << "& 1 other "
    end
<<<<<<< HEAD
    if is_owner
      t << "commented on your prediction."
    else
      t << "commented on #{self.prediction.user.username}'s prediction."
    end
=======
    t << "commented on #{self.prediction.user.username}'s prediction."
>>>>>>> Reworked activities for new feed
    return t
  end
end
