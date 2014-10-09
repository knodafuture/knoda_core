class PredictionMentionActivityNotifier

  def self.deliver(prediction, recipient)
    a = Activity.find_or_initialize_by(user_id: recipient.id, prediction_id: prediction.id, activity_type: 'PREDICTION_MENTION')
    a.title = "Holla! #{prediction.user.username} mentioned you in their prediction."
    a.prediction_body = prediction.body
    if prediction.user.avatar_image
      a.image_url = prediction.user.avatar_image[:small]
    end
    a.created_at = DateTime.now
    a.seen = false
    a.save
  end
end
