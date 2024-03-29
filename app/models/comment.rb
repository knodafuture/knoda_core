class Comment < ActiveRecord::Base
  belongs_to :user, inverse_of: :comments
  belongs_to :prediction, inverse_of: :comments

  validates :user_id, presence: true
  validates :prediction_id, presence: true

  after_create :create_activities
  after_create :detect_hashtags
  after_create :detect_mentions

  include Authority::Abilities
  self.authorizer_name = 'CommentAuthorizer'

  scope :recent, -> { order("comments.created_at DESC") }
  scope :id_lt, -> (i) {where('comments.id < ?', i) if i}
  scope :id_gt, -> (i) {where('comments.id > ?', i) if i}

  def create_activities
    NotifyCommentFollowers.perform_async(self.id)
  end

  def detect_hashtags
    DetectHashtags.perform_async(self.text)
  end

  def detect_mentions
    NotifyMentionedUsers.perform_async(self.id, 'COMMENT')
  end

  def notify_users
    out = ""
    commentingUsers = self.prediction.comments.group_by { |c| c.user_id}
    if self.prediction.user.id != self.user_id
      a = Activity.find_or_initialize_by(user_id: self.prediction.user.id, prediction_id: self.prediction.id, activity_type: 'COMMENT')
      a.title = notification_title(true)
      a.prediction_body = self.prediction.body
      if self.user.avatar_image
        a.image_url = self.user.avatar_image[:small]
      end
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
        a.title = notification_title(false)
        a.prediction_body = self.prediction.body
        if self.user.avatar_image
          a.image_url = self.user.avatar_image[:small]
        end
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

  def notify_mentioned_users
    mentions = self.text.scan(/@(\w+)/).flatten
    mentions.each do |m|
      user = User.where(["lower(username) = :username", {:username => m.downcase }]).first
      if user and (user != self.prediction.user) and (user != self.user)
        CommentMentionActivityNotifier.deliver(self, user)
        if user.notification_settings.where(:setting => 'PUSH_MENTIONS').first.active == true
          CommentMentionPushNotifier.deliver(self, user)
        end
      end
    end
  end

  def to_push_text(is_owner)
    if self.text.length > 100
      comment_text_sub = self.text.slice(0,97) + "..."
    else
      comment_text_sub = self.text.slice(0,100)
    end
    t = notification_title(is_owner)
    t <<  "\"#{comment_text_sub}\""
    return t
  end

  def to_mention_push_text
    if self.text.length > 100
      comment_text_sub = self.text.slice(0,97) + "..."
    else
      comment_text_sub = self.text.slice(0,100)
    end
    t = "#{user.username} mentioned you in their comment. #{comment_text_sub}"
  end

  def notification_title(is_owner)
    commentingUsers = self.prediction.comments.group_by { |c| c.user_id}
    t = "#{self.user.username} "
    if commentingUsers.length > 2
      t << "& #{commentingUsers.length - 1} others "
    elsif commentingUsers.length == 2
      t << "& 1 other "
    end
    #commentingUsers = self.prediction.comments.group_by { |c| c.user_id}
    t = "#{self.user.username} "
    #if commentingUsers.length > 2
    #  t << "& #{commentingUsers.length - 1} others "
    #elsif commentingUsers.length == 2
    #  t << "& 1 other "
    #end
    if is_owner
      t << "commented on a prediction by you."
    else
      t << "commented on a prediction by #{self.prediction.user.username}."
    end
    return t
  end

end
