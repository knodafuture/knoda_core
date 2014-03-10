class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  after_create :generate_code
  #after_create :send_invite

  def invitation_link
    "/join?code=#{self.code}"
  end

  private
    def generate_code
      self.update(:code => "I#{self.id}");
    end

    def send_invite
      if (self.recipient_user_id)
        InvitationMailer.existing_user(self).deliver
      elsif (self.recipient_email)
        InvitationMailer.new_user(self).deliver
      end      
    end        
end
