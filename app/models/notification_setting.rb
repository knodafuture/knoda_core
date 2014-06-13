class NotificationSetting < ActiveRecord::Base
  belongs_to :user, inverse_of: :notification_settings
end
