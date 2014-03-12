class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  after_create :generate_code
  #after_create :send_invite

  scope :unnotified, -> {where('notified_at is null')}

  def invitation_link
    "/join?code=#{self.code}"
  end

  def send_invite
    if (self.recipient_user_id)
      InvitationMailer.existing_user(self).deliver
      InvitationPushNotifier.deliver(self)
    elsif (self.recipient_email)
      InvitationMailer.new_user(self).deliver
    end      
    invitation.update(:notified_at => DateTime.now)
  end          

  private
    def generate_code
      self.update(:code => "I#{self.id}");
    end
end
