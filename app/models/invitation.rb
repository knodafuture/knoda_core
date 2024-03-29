class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  before_create :clean_data
  after_create :generate_code
  after_create :send_invite_activity
  after_create :send_async

  scope :unnotified, -> {where('notified_at is null')}

  validates_format_of :recipient_email, :with => /.+@.+\..+/i, :allow_nil => true

  def invitation_link
    if group_id
      return "#{Rails.application.config.knoda_web_url}/groups/join?code=#{self.code}"
    else
      return "#{Rails.application.config.knoda_web_url}/?invitation_code=#{self.code}"
    end
  end

  def send_async
    SendGroupInvite.perform_async(self.id)
  end

  def send_invite
    begin
      if (self.recipient_user_id and self.recipient_user_id > 0)
        InvitationMailer.inv(self).deliver
        if User.find(self.recipient_user_id).notification_settings.where(:setting => 'PUSH_GROUP_INVITATION').first.active == true
          InvitationPushNotifier.deliver(self)
        end
      elsif (self.recipient_email)
        InvitationMailer.inv(self).deliver
      elsif (self.recipient_phone)
        InvitationSmsNotifier.deliver(self)
      end
    rescue
      puts 'Exception raised sending invitation'
    else
      self.update(:notified_at => DateTime.now)
    end
  end

  def send_invite_activity
    if (self.recipient_user_id and self.recipient_user_id > 0)
      InvitationActivityNotifier.deliver(self)
    end
  end

  private
    def clean_data
      if self.recipient_phone
        PhoneSanitizer.sanitize(self.recipient_phone)
      end
    end

    def generate_code
      last4 = Time.now.strftime('%Y%m%d%H%M%S%L')[-4,4]
      code = "I"
      "#{self.id}#{last4}".each_char do|c|
        code << number_to_letter(c)
      end
      self.update(:code => code);
    end

    def number_to_letter(n=1)
      n.to_i.to_s(27).tr("0-9a-q", "A-Z")
    end
end
