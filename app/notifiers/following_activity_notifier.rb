class FollowingActivityNotifier

  def self.deliver(following)
    a = Activity.find_or_initialize_by(user_id: following.leader_id, target_user_id: following.user.id, activity_type: 'FOLLOWING')
    a.image_url = following.user.avatar_image[:small]
    a.title = "#{following.user.username} is now following you on Knoda."
    a.created_at = DateTime.now
    a.seen = false
    a.save!
  end
end
