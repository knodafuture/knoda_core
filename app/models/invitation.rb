class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  before_create :clean_data
  after_create :generate_code

  scope :unnotified, -> {where('notified_at is null')}

  def invitation_link
    "#{Rails.application.config.knoda_web_url}/groups/join?code=#{self.code}"
  end

  def send_invite
    begin
      if (self.recipient_user_id and self.recipient_user_id > 0)
        InvitationMailer.inv(self).deliver
        InvitationPushNotifier.deliver(self)
        InvitationActivityNotifier.deliver(self)
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

  private
    def clean_data
      puts self.recipient_phone
      if self.recipient_phone
        self.recipient_phone.gsub!('(', '')
        self.recipient_phone.gsub!(')', '')
        self.recipient_phone.gsub!(' ', '')
        self.recipient_phone.gsub!('-', '')
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
