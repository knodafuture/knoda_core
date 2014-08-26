class Following < ActiveRecord::Base
  belongs_to :user
  belongs_to :leader, :class_name => "User"
  after_create :post_create
  after_create :delete_inverse_notification

  def post_create
    NotifyLeader.perform_async(self.id)
  end

  def delete_inverse_notification
    Activity.where(user_id: self.user_id, target_user_id: self.leader_id, activity_type: 'FOLLOWING').delete_all
  end

  def notify_leader
    FollowingActivityNotifier.deliver(self)
    if self.leader.notification_settings.where(:setting => 'PUSH_FOLLOWINGS').first.active == true
      FollowingPushNotifier.deliver(self)
    end
  end

  def push_text
    return "#{user.username} is now following you on Knoda."
  end

end
