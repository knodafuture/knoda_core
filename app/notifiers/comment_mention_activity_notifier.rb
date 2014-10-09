class CommentMentionActivityNotifier

  def self.deliver(comment, recipient)
    a = Activity.find_or_initialize_by(user_id: recipient.id, prediction_id: comment.prediction.id, activity_type: 'COMMENT_MENTION')
    a.title = "#{comment.user.username} mentioned you in their comment."
    a.prediction_body = comment.prediction.body
    a.comment_body = comment.text
    if comment.user.avatar_image
      a.image_url = comment.user.avatar_image[:small]
    end
    a.created_at = DateTime.now
    a.seen = false
    a.save!
  end
end
